class Drink < ApplicationRecord
  has_and_belongs_to_many :users

  def self.pluralize(count)
    "#{count} #{Russian::p(count, 'раз', 'раза', 'раз')}"
  end
end
