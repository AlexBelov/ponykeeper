class Book < ApplicationRecord
  has_and_belongs_to_many :users

  SITES = %w(livelib.ru goodreads.com fimfiction.net fantlab.ru ficbook.net samlib.ru author.today flibusta).freeze

  def self.detect_book_mention(payload)
    book = extract_book(payload)
    return nil unless book.present?
    "Своим библиотекарским чутьём я вижу, что вы упомянули книгу. Чтобы добавить книгу в процессе чтения используйте команду */add_book ссылка_на_книгу*"
  rescue
    nil
  end

  def self.add_book(user, payload)
    book = extract_book(payload)
    response = if user.books_users.where(book_id: book.id, finished: true).present?
      "Вы уже прочитали эту книгу"
    elsif user.books_users.where(book_id: book.id, finished: false).today.present?
      "Сегодня вы уже читали эту книгу"
    elsif user.books_users.where(book_id: book.id, finished: false).present?
      user.books << book
      "#{user.full_name} продолжает читать [книгу](#{book.url})"
    else
      user.books << book
      "#{user.full_name} начинает читать новую книгу"
    end
    return response
  rescue
    nil
  end

    def self.finish_book(user, payload)
    book = extract_book(payload)
    response = if user.books_users.where(book_id: book.id, finished: true).present?
      "Вы уже прочитали эту книгу"
    else
      user.books << book
      BooksUser.create(book_id: book.id, user_id: user.id, finished: true)
      "Теперь #{user.full_name} прочитал #{Book.pluralize(user.books_users.where(finished: true).count)}! (#{Book.pluralize(user.books_finished_this_month)} за этот месяц)"
    end
    return response
  rescue Exception => e
    puts "Exception in finish book - #{e.message}".red
    nil
  end

  def self.pluralize(count)
    "#{count} #{Russian::p(count, 'книгу', 'книги', 'книг')}"
  end

  def self.extract_book(payload)
    return unless payload.match?(Regexp.new(SITES.join('|')))
    url = URI.extract(payload).first
    Book.where(url: url).first_or_create
  rescue
    nil
  end
end
