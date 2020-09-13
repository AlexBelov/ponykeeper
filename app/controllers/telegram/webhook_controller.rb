class Telegram::WebhookController < Telegram::Bot::UpdatesController
  def message(message)
    response = '';
    user = User.handle_user(message['from'])
    check_for_achievements = true
    if message['new_chat_participant'].present?
      message = Message.find_by(slug: 'welcome')
      return unless message.present?
      response = message.interpolate({first_name: User.get_full_name(message)})
      response = Message.add_random_image(response)
      check_for_achievements = false
    elsif message['text'].present?
      response = Book.detect_book_mention(message['text'])
    elsif message['photo'].present?
      response = Drink.handle_drink(user, message)
    end
    return unless response.present?
    respond_with :message, text: response, parse_mode: :Markdown
    return unless check_for_achievements
    achievements = user.check_for_achievements
    if achievements.present?
      achievements.each{|a| respond_with :message, text: a.response(user), parse_mode: :Markdown}
    end
    ranks = user.check_for_ranks
    if ranks.present?
      ranks.each{|r| respond_with :message, text: r.response(user), parse_mode: :Markdown}
    end
  rescue Exception => e
    puts "Error in message handler - #{e.message}".red
    return true
  end

  def rules!(data = nil, *)
    message = Message.find_by(slug: 'rules')
    return unless message.present?
    response = message.interpolate([])
    return unless response.present?
    respond_with :message, text: response
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def roll!(data = nil, *)
    result = ['Пить =)', 'Не пить =('].sample
    response = "Пить или не пить? - *#{result}*"
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def top_books!(data = nil, *)
    ordered_books = Book.joins(:users).order("COUNT(users.id) DESC").group("books.id").limit(5)
    response = ordered_books.each_with_index.map{|b, i| "#{i + 1}. #{b.url}"}.join("\n")
    respond_with :message, text: "*Топ книг*\n" + response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def top_drinks!(data = nil, *)
    ordered_drinks = Drink.joins(:users).order("COUNT(users.id) DESC").group("drinks.id").limit(5)
    response = ordered_drinks.each_with_index.map{|d, i| "#{i + 1}. #{d.name}"}.join("\n")
    respond_with :message, text: "*Топ бухла*\n" + response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def top_readers!(data = nil, *)
    ordered_users = User.joins(:books).order("COUNT(books.id) DESC").group("users.id").limit(5)
    response = ordered_users.each_with_index.map{|u, i| "#{i + 1}. #{u.full_name}"}.join("\n")
    respond_with :message, text: "*Топ читателей*\n" + response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def top_drinkers!(data = nil, *)
    ordered_users = User.joins(:drinks).order("COUNT(drinks.id) DESC").group("users.id").limit(5)
    response = ordered_users.each_with_index.map{|u, i| "#{i + 1}. #{u.full_name}"}.join("\n")
    respond_with :message, text: "*Топ алкоголиков*\n" + response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def has_drink!(data = nil, *)
    existing_drink = Drink.find_by(name: data.downcase)
    response = if existing_drink.present?
      "У нас есть напиток *#{existing_drink.name}*"
    else
      "Напиток *#{data.downcase}* ещё не добавлен. Добавление возможно с помощью команды */add_drink *"
    end
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def add_drink!(data = nil, *)
    return unless data.present?
    existing_drink = Drink.find_by(name: data.downcase)
    response = if existing_drink.present?
      "У нас уже есть напиток *#{existing_drink.name}*"
    else
      new_drink = Drink.where(name: data.downcase).first_or_create
      "Напиток *#{new_drink.name}* добавлен. Теперь его можно использовать в качестве тега"
    end
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def add_book!(data = nil, *)
    user = User.handle_user(from)
    return unless user.present?
    response = Book.add_book(user, data)
    return unless response.present?
    respond_with :message, text: response, parse_mode: :Markdown
    achievements =  user.check_for_achievements
    if achievements.present?
      achievements.each{|a| respond_with :message, text: a.response(user), parse_mode: :Markdown}
    end
    ranks = user.check_for_ranks
    if ranks.present?
      ranks.each{|r| respond_with :message, text: r.response(user), parse_mode: :Markdown}
    end
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def finish_book!(data = nil, *)
    user = User.handle_user(from)
    return unless user.present?
    response = Book.finish_book(user, data)
    return unless response.present?
    respond_with :message, text: response, parse_mode: :Markdown
    achievements =  user.check_for_achievements
    if achievements.present?
      achievements.each{|a| respond_with :message, text: a.response(user), parse_mode: :Markdown}
    end
    ranks = user.check_for_ranks
    if ranks.present?
      ranks.each{|r| respond_with :message, text: r.response(user), parse_mode: :Markdown}
    end
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def all_achievements!(data = nil, *)
    user = User.handle_user(from)
    return unless user.present?
    response = Achievement.all.each_with_index.map{|a, i| "#{i+1}. *#{a.name}* - _#{a.description}_"}.join("\n")
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def my_achievements!(data = nil, *)
    user = User.handle_user(from)
    return unless user.present?
    response = user.achievements.uniq.each_with_index.map{|a, i| "#{i+1}. *#{a.name}* - _#{a.description}_"}.join("\n")
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end
end