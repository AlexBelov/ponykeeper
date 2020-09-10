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
      has_drinks = text.match?(Regexp.new(Drink::SITES.join('|')))
      return unless has_books || has_drinks
      response = "";
      user = User.handle_user(message['from'])
      if has_books
        book = Book.handle_book(message['text'])
        return if user.books.include?(book)
        user.books << book
        response = "Теперь #{user.full_name} прочитал #{Book.pluralize(user.books.count)}! (#{Book.pluralize(user.books_this_month)} за этот месяц)"
      elsif has_drinks
        drink = Drink.handle_drink(message['text'])
        user.drinks << drink
        response = "Теперь #{user.full_name} выпил #{Drink.pluralize(user.drinks.count)}! (#{Drink.pluralize(user.drinks_this_month)} за этот месяц)"
      end
      return unless response.present?
      respond_with :message, text: response, parse_mode: :Markdown
    end
  end

  def top_books!(data = nil, *)
    response = "Здесь будет топ книг"
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def top_drinks!(data = nil, *)
    response = "Здесь будет топ бухла"
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def top_readers!(data = nil, *)
    response = "Здесь будет топ читателей"
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end

  def top_drinkers!(data = nil, *)
    response = "Здесь будет топ алкоголиков"
    respond_with :message, text: response, parse_mode: :Markdown
  rescue Exception => e
    puts "Error in command handler".red
    puts e.message
  end
end