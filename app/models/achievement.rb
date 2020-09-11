class Achievement < ApplicationRecord
  has_and_belongs_to_many :users

  def self.check_for_achievements(user)
    drinks_today = user.drinks_users.today
    books_today = user.books_users.today
    achievement = if drinks_today && !user.has_achievement_today?(Achievement.find_by(slug: 'good_day'))
      find_by(slug: 'good_day')
    elsif drinks_today && books_today && !user.has_achievement_today?(Achievement.find_by(slug: 'drink_and_read'))
      find_by(slug: 'drink_and_read')
    elsif drinks_today > 3 &&  !user.has_achievement_today?(Achievement.find_by(slug: 'non_stop'))
      find_by(slug: 'non_stop')
    end
    return nil unless achievement.present?
    user.achievements << achievement
    achievement
  end

  def response(user)
    "*#{user.full_name}* получает достижение *#{name}*!\n_#{description}_[\u200c](#{Image.random})"
  end
end
