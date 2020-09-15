class BotCommand < ApplicationRecord
  after_save :set_commands

  def self.list_of_commands
    self.all.map{|bc| "/#{bc.name} - #{bc.description}"}.join("\n")
  end

  def set_commands
    Telegram.bot.set_my_commands({
      commands: BotCommand.all.map{|bc| {command: bc.name, description: bc.description}}
    })
  end
end
