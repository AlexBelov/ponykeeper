class Drink < ApplicationRecord
  has_and_belongs_to_many :users

  def self.handle_drink(user, payload)
    file_id = payload['photo'].first['file_id']
    tags = payload['caption'].split('#').map(&:strip).filter{|t| t.present?}
    return nil unless tags.present?
    available_drink = Drink.where(name: tags).first
    return "Не могу найти напиток в картотеке" unless available_drink.present?
    abv = handle_abv(tags)
    volume = handle_volume(tags)
    DrinksUser.create(user: user, drink: available_drink, abv: abv, volume: volume)
    return "Теперь #{user.full_name} выпил #{Drink.pluralize(user.drinks.count)}! (#{Drink.pluralize(user.drinks_this_month)} за этот месяц)"
  rescue
    nil
  end

  def self.pluralize(count)
    "#{count} #{Russian::p(count, 'раз', 'раза', 'раз')}"
  end

  private

  def handle_abv(tags)
    abv_tag = tags.find{|t| t.match(/abv/)}
    abv_tag.gsub('abv', '').gsub('_', '.').to_f
  rescue
    nil
  end

  def handle_volume(tags)
    volume_tag = tags.find{|t| t.match(/volume/)}
    volume_tag.gsub('abv', '').gsub('_', '.').to_f
  rescue
    nil
  end
end
