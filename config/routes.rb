Rails.application.routes.draw do
  devise_for :admins
  mount RailsAdmin::Engine => '/', as: 'rails_admin'
  telegram_webhook Telegram::WebhookController
end
