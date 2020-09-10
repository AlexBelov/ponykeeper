class Drink < ApplicationRecord
  has_and_belongs_to_many :users

  SITES = %w(untappd).freeze

  def self.handle_drink(payload)
    url = URI.extract(payload).first
    Drink.where(url: url).first_or_create
  end

  def self.pluralize(count)
    "#{count} #{Russian::p(count, 'раз', 'раза', 'раз')}"
  end
end
