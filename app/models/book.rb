class Book < ApplicationRecord
  has_and_belongs_to_many :users

  SITES = %w(livelib.ru goodreads.com fimfiction.net fantlab.ru ficbook.net samlib.ru author.today flibusta).freeze

  def self.detect_book_mention(payload)
    book = extract_book(payload)
    "Своим библиотекарским чутьём я вижу, что вы упомянули книгу. Чтобы добавить книгу в прочитанное используйте команду */add_book ссылка_на_книгу*"
  rescue
    nil
  end

  def self.add_book(user, payload)
    book = extract_book(payload)
    return if user.books.include?(book)
      "Вы уже читали эту книгу"
    else
      user.books << book
      "Теперь #{user.full_name} прочитал #{Book.pluralize(user.books.count)}! (#{Book.pluralize(user.books_this_month)} за этот месяц)"
    end
  end

  def self.pluralize(count)
    "#{count} #{Russian::p(count, 'книгу', 'книги', 'книг')}"
  end

  private

  def extract_book(payload)
    return unless payload['text'].match?(Regexp.new(SITES.join('|')))
    url = URI.extract(payload['text']).first
    Book.where(url: url).first_or_create
  rescue
    nil
  end
end
