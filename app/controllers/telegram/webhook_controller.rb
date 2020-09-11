class Telegram::WebhookController < Telegram::Bot::UpdatesController
  def message(message)
    if message['new_chat_participant'].present?
      response = "Добро пожаловать в Бухотеку Мэйнхэттена, *#{User.get_full_name(message['new_chat_participant'])}*!\n\nУ нас можно (и нужно) обсуждать книги и алкоголь.\nБот считает ссылки на основные книжные сайты (#{Book::SITES.join(', ')}) и untappd и раздаёт ачивки алкоголикам и тунеядцам!"
      response += "[\u200c](https://i1.7fon.org/1000/g489563.jpg)"
      respond_with :message, text: response, parse_mode: :Markdown
    else
      text = message['text']
      return unless text.present?
      has_books = text.match?(Regexp.new(Book::SITES.join('|')));
      return unless has_books || has_drinks
      response = "";
      user = User.handle_user(message['from'])
      if has_books
        book = Book.handle_book(message['text'])
        return unless book.present?
        response = "Своим библиотекарским чутьём я вижу, что вы упомянули книгу. Чтобы добавить книгу в прочитанное используйте команду */add_book ссылка_на_книгу*"
      # elsif has_drinks
        # drink = Drink.handle_drink(message['text'])
        # return unless drink.present?
        # user.drinks << drink
        # response = "Теперь #{user.full_name} выпил #{Drink.pluralize(user.drinks.count)}! (#{Drink.pluralize(user.drinks_this_month)} за этот месяц)"
      end
      return unless response.present?
      respond_with :message, text: response, parse_mode: :Markdown
    end
  rescue Exception => e
    puts "Error in message handler - #{e.message}".red
    return true
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
    response = ordered_drinks.each_with_index.map{|d, i| "#{i + 1}. #{d.url}"}.join("\n")
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
    book = Book.handle_book(data)
    return unless book.present?
    response = if user.books.include?(book)
      "Вы уже читали эту книгу"
    else
      user.books << book
      "Теперь #{user.full_name} прочитал #{Book.pluralize(user.books.count)}! (#{Book.pluralize(user.books_this_month)} за этот месяц)"
    end
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end
end