namespace :daily do
  desc "Person of a day"
  task person_of_a_day: :environment do
    chat_id = Chat.main_chat_id
    return unless chat_id.present?
    user = User.where.not(username: [nil, '']).sample
    message = Message.find_by(slug: 'person_of_a_day')
    return unless message.present?
    response = message.interpolate({username: "@#{user.username}"})
    response = Message.add_image(response, :drink)
    Telegram.bot.send_message({text: response, chat_id: chat_id, parse_mode: :Markdown})
  end
end