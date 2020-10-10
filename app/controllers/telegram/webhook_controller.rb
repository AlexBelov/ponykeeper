class Telegram::WebhookController < Telegram::Bot::UpdatesController
  include ActionView::Helpers::DateHelper

  def message(message)
    response = '';
    user = User.handle_user(message['from'])
    user.update_columns(last_message_at: Time.current)
    check_for_achievements = false
    if message['new_chat_participant'].present?
      msg = Message.find_by(slug: 'welcome')
      return unless msg.present?
      response = msg.interpolate({first_name: User.get_full_name(message['new_chat_participant'])})
      response = Message.add_random_image(response)
    elsif message['text'].present? && message['text'] == '!kick'
      response = kick_or_ban(message, false)
    elsif message['text'].present? && message['text'] == '!ban'
      response = kick_or_ban(message, true)
    elsif message['text'].present? && message['text'].include?('!mute')
      response = mute_or_unmute(message, false)
    elsif message['text'].present? && message['text'].include?('!unmute')
      response = mute_or_unmute(message, true)
    elsif message['text'].present? && message['text'].include?('!warn')
      response = warn(message)
    elsif message['text'].present? && message['text'].include?('!restrict_media')
      response = mute_or_unmute(message, true, true)
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
    respond_with :message, text: response
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
    until_date = ban ? (Time.current + 2.years).to_i : (Time.current + 1.minute).to_i
    Telegram.bot.kick_chat_member({chat_id: Rails.application.credentials.telegram[:bot][:chat_id].to_i, user_id: user_id, until_date: until_date})
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
      chat_id: Rails.application.credentials.telegram[:bot][:chat_id].to_i,
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
        chat_id: Rails.application.credentials.telegram[:bot][:chat_id].to_i,
        user_id: user_id,
        until_date: until_date
      })
      return "#{name} получил #{warns_limit} предупреждений и был кикнут"
    end
    "#{name} получил #{user.warns} предупреждений из #{warns_limit}"
  end
end