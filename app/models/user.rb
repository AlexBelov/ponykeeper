class User < ApplicationRecord
  has_one :admin
  belongs_to :group

  def full_name
    [first_name, last_name].join(' ').strip
  end

  def full_name_or_username
    full_name.present? ? full_name : username
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

  rails_admin do
    list do
      field :id
      field :group
      include_all_fields
    end
  end
end
