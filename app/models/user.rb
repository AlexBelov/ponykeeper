class User < ApplicationRecord
  has_one :admin

  def full_name
    [first_name, last_name].join(' ').strip
  end

  def title
    "##{id} #{username}"
  end

  def self.get_full_name(from)
    return 'Анон' unless from.present?
    [from['first_name'], from['last_name']].join(' ').strip
  end

  def self.handle_user(from)
    return true unless from.present?
    User.where(telegram_id: from['id']).first_or_create(first_name: from['first_name'], last_name: from['last_name'], username: from['username'])
  end
end
