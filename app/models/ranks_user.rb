class RanksUser < ApplicationRecord
  belongs_to :user
  belongs_to :rank
end