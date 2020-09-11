class User < ApplicationRecord
  has_many :drinks_users
  has_many :books_users
  has_many :achievements_users
  has_and_belongs_to_many :books
  has_and_belongs_to_many :drinks
  has_and_belongs_to_many :achievements

  def full_name
    [first_name, last_name].join(' ').strip
  end

  def check_for_achievements
    Achievement.check_for_achievements(self)
  end

  def has_achievement_today?(achievement)
    achievements_users.today.where(achievement_id: achievement.id).present?
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
