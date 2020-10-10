
class Chat < ApplicationRecord
  enum role: [:main, :report]

  def self.handle_chat(message)
    chat_data = message['chat']
    return nil unless chat_data['id']
    where(telegram_id: chat_data['id']).first_or_create(
      title: chat_data['title'],
      group_type: chat_data['type']
    )
  rescue
    nil
  end

  def self.main_chat_id
    where(role: :main).try(:telegram_id).to_i
  end
end