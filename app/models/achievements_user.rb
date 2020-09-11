class AchievementsUser < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
end