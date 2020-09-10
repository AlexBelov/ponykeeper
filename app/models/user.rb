class User < ApplicationRecord
  has_and_belongs_to_many :books
  has_and_belongs_to_many :drinks

  def full_name
    [first_name, last_name].join(' ').strip
  end

  def self.get_full_name(from)
    return 'Анон' unless from.present?
    [from['first_name'], from['last_name']].join(' ').strip
  end

  def self.handle_user(from)
    return true unless from.present?
    User.where(telegram_id: from['id']).first_or_create(first_name: from['first_name'], last_name: from['last_name'], username: from['username'])
  end

  def books_this_month
    BooksUser.where(user_id: id).after(Time.current.beginning_of_month).count
  end

  def drinks_this_month
    DrinksUser.where(user_id: id).after(Time.current.beginning_of_month).count
  end
end
