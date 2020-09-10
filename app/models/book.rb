class Book < ApplicationRecord
  has_and_belongs_to_many :users

  SITES = %w(livelib.ru goodreads.com fimfiction.net fantlab.ru ficbook.net samlib.ru author.today flibusta).freeze

  def self.handle_book(payload)
    url = URI.extract(payload).first
    Book.where(url: url).first_or_create
  end

  def self.pluralize(count)
    "#{count} #{Russian::p(count, 'книгу', 'книги', 'книг')}"
  end
end
