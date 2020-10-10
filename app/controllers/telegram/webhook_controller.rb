class Telegram::WebhookController < Telegram::Bot::UpdatesController
  include ActionView::Helpers::DateHelper

  def message(message)
    Chat.handle_chat(message)
    response = '';
    user = User.handle_user(message['from'])
    user.update_columns(last_message_at: Time.current)
    check_for_achievements = false
    reputation_words = Config.
      where(key: ['reputation_increase_words', 'reputation_decrease_words']).
      pluck(:value).
      join(',').
      split(',').
      map{|w| w.downcase.strip}
    response = if message['new_chat_participant'].present?
      new_user = User.handle_user(message['new_chat_participant'])
      new_user.update(status: :active)
      msg = Message.find_by(slug: 'welcome')
      return unless msg.present?
      Chat.send_report_message("[#{new_user.full_name_or_username}](tg://user?id=#{new_user.id}) добавился в чат")
      response = msg.interpolate({first_name: User.get_full_name(message['new_chat_participant'])})
      Message.add_random_image(response)
    elsif message['left_chat_participant'].present?
      user_left = User.handle_user(message['left_chat_participant'])
      user_left.update(status: :left)
      Chat.send_report_message("[#{user_left.full_name_or_username}](tg://user?id=#{user_left.id}) покинул чат")
      nil
    elsif message['text'].present? && message['text'] == '!kick'
      response = kick_or_ban(message, false)
      Chat.send_report_message(response)
      response
    elsif message['text'].present? && message['text'] == '!ban'
      response = kick_or_ban(message, true)
      Chat.send_report_message(response)
      response
    elsif message['text'].present? && message['text'].include?('!mute')
      response = mute_or_unmute(message, false)
      Chat.send_report_message(response)
      response
    elsif message['text'].present? && message['text'].include?('!unmute')
      response = mute_or_unmute(message, true)
      Chat.send_report_message(response)
      response
    elsif message['text'].present? && message['text'].include?('!warn')
      response = warn(message)
      Chat.send_report_message(response)
      response
    elsif message['text'].present? && message['text'].include?('!restrict_media')
      response = mute_or_unmute(message, true, true)
      Chat.send_report_message(response)
      response
    elsif message['text'].present? && message['text'].include?('!report')
      report(message)
    elsif message['text'].present? && reputation_words.map{|w| message['text'].include?(w)}.any?
      response = reputation(message)
      Chat.send_report_message(response)
      response
    end
    return unless response.present?
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in message handler - #{e.message}".red
    return true
  end

  def rules!(data = nil, *)
    message = Message.find_by(slug: 'rules')
    return unless message.present?
    response = message.interpolate({})
    return unless response.present?
    respond_with :message, text: response, disable_web_page_preview: true
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def help!(data = nil, *)
    message = Message.find_by(slug: 'help')
    return unless message.present?
    response = message.interpolate({bot_commands: BotCommand.list_of_commands})
    return unless response.present?
    respond_with :message, text: response
  end

  def ship!(data = nil, *)
    message = Message.find_by(slug: 'ship')
    return unless message.present?
    shippering_period = Config.find_by(key: 'shippering_period_hours').value.to_f
    last_shippering = Config.find_by(key: 'last_shippering')
    last_shippering_at = begin Time.parse(last_shippering.value) rescue Time.current - 1.year end
    time_difference = (Time.current - last_shippering_at) / 1.hour
    if time_difference < shippering_period
      next_shippering = (shippering_period - time_difference).to_i
      respond_with :message, text: "Пара дня уже выбрана. Новую пару можно будет выбрать через #{next_shippering} #{Russian::p(next_shippering, 'час', 'часа', 'часов', 'часа')}."
      return
    end
    first = User.all.sample
    second = User.where.not(id: first.id).sample
    response = message.interpolate({
      first: "[#{first.full_name_or_username}](tg://user?id=#{first.id})",
      second: "[#{second.full_name_or_username}](tg://user?id=#{second.id})",
    })
    last_shippering.update(value: Time.current)
    respond_with :message, text: response, parse_mode: :Markdown
  end

  def from!(data = nil, *)
    payload = data.downcase
    sanitized_payload = "%#{User.sanitize_sql_like(payload)}%"
    users = User.joins(:city, :country).where("cities.name ILIKE ? OR countries.name ILIKE ?", sanitized_payload, sanitized_payload).order(:id)
    response = users.each_with_index.map{|u, i| "#{i + 1}. #{u.full_name_or_username}"}.join("\n")
    respond_with :message, text: "*Поняши из #{payload.capitalize}*\n" + response, parse_mode: :Markdown
  end

  private

  def kick_or_ban(message, ban = false)
    user = User.handle_user(message['from'])
    return unless user.present? && user.admin.present?
    return unless message['reply_to_message'].present?
    new_participant = message['reply_to_message']['new_chat_participant']
    message_from = message['reply_to_message']['from']
    cannot_kick_usernames = Admin.where.not(user_id: nil).includes(:user).pluck(:username).concat([Rails.application.credentials.telegram[:bot][:username]])
    user_id, name = if new_participant.present?
      [new_participant['id'], [new_participant['first_name'], new_participant['last_name']].join(' ')]
    elsif message_from.present? && !cannot_kick_usernames.include?(message_from['username'])
      [message_from['id'], [message_from['first_name'], message_from['last_name']].join(' ')]
    end
    return "Не могу #{ban ? 'забанить' : 'кикнуть'} пользователя" unless user_id.present?
    target_user = User.find_by(telegram_id: user_id)
    target_user.update(status: ban ? :banned : :kicked)
    until_date = ban ? (Time.current + 2.years).to_i : (Time.current + 1.minute).to_i
    Telegram.bot.kick_chat_member({chat_id: Chat.main_chat_id, user_id: user_id, until_date: until_date})
    "*#{user.full_name}* #{ban ? 'забанил' : 'кикнул'} *#{name}*"
  end

  def mute_or_unmute(message, unmute = false, restrict_media = false)
    user = User.handle_user(message['from'])
    mute_for = message['text'].gsub('!mute', '').strip
    mute_for = '1 hour' unless mute_for.present?
    mute_for = '3 years' if unmute
    return unless user.present? && user.admin.present?
    return unless message['reply_to_message'].present?
    new_participant = message['reply_to_message']['new_chat_participant']
    message_from = message['reply_to_message']['from']
    cannot_kick_usernames = Admin.where.not(user_id: nil).includes(:user).pluck(:username).concat([Rails.application.credentials.telegram[:bot][:username]])
    user_id, name = if new_participant.present?
      [new_participant['id'], [new_participant['first_name'], new_participant['last_name']].join(' ')]
    elsif message_from.present? && !cannot_kick_usernames.include?(message_from['username'])
      [message_from['id'], [message_from['first_name'], message_from['last_name']].join(' ')]
    end
    return "Не могу замьютить пользователя" unless user_id.present?
    value = begin mute_for.scan(/\d+/)[0].to_i rescue 2 end
    mute_time, unit =
    if mute_for.include?('year')
      value.years
    elsif mute_for.include?('month')
      value.months
    elsif mute_for.include?('week')
      value.weeks
    elsif mute_for.include?('day')
      value.days
    elsif mute_for.include?('hour')
      value.hours
    else
      value.years
    end
    until_time = Time.current + mute_time
    permissions = {
      can_send_messages: unmute,
      can_send_media_messages: unmute && !restrict_media,
      can_send_polls: unmute && !restrict_media,
      can_send_other_messages: unmute && !restrict_media,
      can_add_web_page_previews: unmute && !restrict_media
    }
    Telegram.bot.restrict_chat_member({
      chat_id: Chat.main_chat_id,
      user_id: user_id,
      permissions: permissions,
      until_date: until_time.to_i
    })
    return "*#{user.full_name}* запретил *#{name}* медиа-сообщения" if restrict_media
    return "*#{user.full_name}* cнял мьют с *#{name}*" if unmute
    "*#{user.full_name}* замьютил *#{name}* на #{distance_of_time_in_words(Time.current, until_time)}"
  end

  def warn(message)
    user = User.handle_user(message['from'])
    return unless user.present? && user.admin.present?
    cannot_kick_usernames = Admin.where.not(user_id: nil).includes(:user).pluck(:username).concat([Rails.application.credentials.telegram[:bot][:username]])
    message_from = message['reply_to_message']['from']
    user_id, name = if message_from.present? && !cannot_kick_usernames.include?(message_from['username'])
      [message_from['id'], [message_from['first_name'], message_from['last_name']].join(' ')]
    end
    return "Не могу выдать пользователю warn" unless user_id.present?
    user.update_columns(warns: user.warns + 1)
    warns_limit = Config.find_by(key: 'warns_limit').value.to_i
    response = ''
    if user.warns >= warns_limit
      user.update_columns(warns: 0)
      until_date = (Time.current + 1.minute).to_i
      Telegram.bot.kick_chat_member({
        chat_id: Chat.main_chat_id,
        user_id: user_id,
        until_date: until_date
      })
      return "#{name} получил #{warns_limit} предупреждений и был кикнут"
    end
    "#{name} получил #{user.warns} предупреждений из #{warns_limit}"
  end

  def reputation(message)
    user = User.handle_user(message['from'])
    reputation_user = begin User.handle_user(message['reply_to_message']['from']) rescue nil end
    return unless user.present? && reputation_user.present? && user.id != reputation_user.id
    reputation_increase_words = Config.find_by(key: 'reputation_increase_words').
      value.
      split(',').
      map{|w| w.downcase.strip}
    reputation_deccrease_words = Config.find_by(key: 'reputation_decrease_words').
      value.
      split(',').
      map{|w| w.downcase.strip}
    text = message['text']
    reputation = reputation_user.reputation
    message = if reputation_increase_words.map{|w| text.include?(w)}.any?
      reputation += 1
      Message.find_by(slug: 'reputation_increase')
    elsif reputation_deccrease_words.map{|w| text.include?(w)}.any?
      reputation -= 1
      reputation = 0 if reputation < 0
      Message.find_by(slug: 'reputation_decrease')
    else
      nil
    end
    return nil unless message.present?
    reputation_user.update(reputation: reputation)
    response = message.interpolate({
      first: "[#{user.full_name_or_username}](tg://user?id=#{user.id})",
      second: "[#{reputation_user.full_name_or_username}](tg://user?id=#{reputation_user.id})",
      reputation: reputation
    })
  end

  def report(message)
    user = User.handle_user(message['from'])
    reply_to = message['reply_to_message']
    return unless reply_to.present?
    message_link = "https://t.me/c/#{reply_to['chat']['id'].to_s.gsub(/^-100/, '')}/#{reply_to['message_id']}"
    Chat.send_report_message("[#{user.full_name_or_username}](tg://user?id=#{user.id}) сообщает о [нарушении](#{message_link})")
    "О нарушении сообщено администраторам"
  end
end