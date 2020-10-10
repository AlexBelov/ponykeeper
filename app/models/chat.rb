
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
    find_by(role: :main).try(:telegram_id).to_i
  end

  def self.report_chat_id
    find_by(role: :report).try(:telegram_id).to_i
  end

  def self.send_report_message(message)
    Telegram.bot.send_message({
      text: message,
      chat_id: self.report_chat_id,
      parse_mode: :Markdown
    })
  rescue
    nil
  end
end