Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/', as: 'rails_admin'
  telegram_webhook Telegram::WebhookController
end
