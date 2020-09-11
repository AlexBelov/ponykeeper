class Telegram::WebhookController < Telegram::Bot::UpdatesController
  def message(message)
    response = '';
    user = User.handle_user(message['from'])
    if message['new_chat_participant'].present?
      response = "Добро пожаловать в Бухотеку Мэйнхэттена, *#{User.get_full_name(message['new_chat_participant'])}*!\n\nУ нас можно (и нужно) обсуждать книги и алкоголь.\nНажмите /rules чтобы получить справку по боту, он умеет много полезных штук!"
      response += "[\u200c](#{Image.random})"
      respond_with :message, text: response, parse_mode: :Markdown
    elsif message['text'].present?
      response = Book.detect_book_mention(message['text'])
    elsif message['photo'].present?
      response = Drink.handle_drink(user, message)
    end
    return unless response.present?
    respond_with :message, text: response, parse_mode: :Markdown
    achievement = user.check_for_achievements
    if achievement.present?
      respond_with :message, text: achievement.response(user), parse_mode: :Markdown
    end
  rescue Exception => e
    puts "Error in message handler - #{e.message}".red
    return true
  end

  def rules!(data = nil, *)
    response = Message.find_by(slug: 'rules').try(:content)
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
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end
end