class Drink < ApplicationRecord
  has_and_belongs_to_many :users

  def self.handle_drink(user, payload)
    file_id = payload['photo'].first['file_id']
    return unless payload['caption'].include?('#')
    tags = payload['caption'].split('#').map(&:strip).filter{|t| t.present?}.map(&:downcase)
    return nil unless tags.present?
    drink = Drink.where(name: tags).first
    return "Не могу найти напиток в картотеке" unless drink.present?
    abv = handle_abv(tags)
    volume = handle_volume(tags)
    DrinksUser.create(user: user, drink: drink, abv: abv, volume: volume, file_id: file_id)
    return "Добавлено #{drink.name} #{abv || '0'}% #{volume.to_i || '0'} мл\nТеперь #{user.full_name} выпил #{Drink.pluralize(user.drinks.count)}! (#{Drink.pluralize(user.drinks_today)} за сегодня)"
  rescue Exception => e
    puts "Exception in handle drink - #{e.message}".red
    nil
  end

  def self.pluralize(count)
    "#{count} #{Russian::p(count, 'раз', 'раза', 'раз')}"
  end

  def self.handle_abv(tags)
    abv_tag = tags.find{|t| t.match(/^(abv|a|а)/)}
    abv_tag.scan(/[\d|_]+/).first.gsub('_', '.').to_f
  rescue
    nil
  end

  def self.handle_volume(tags)
    volume_tag = tags.find{|t| t.match(/^(vol|v)/)}
    volume_tag.gsub('vol', '').scan(/\d+/).first.to_f
  rescue
    nil
  end
end
