class Message < ApplicationRecord
  def interpolate(params)
    content % params
  end

  def self.add_random_image(text)
    "#{text}[\u200c](#{Image.random})"
  end
end
