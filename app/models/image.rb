class Image < ApplicationRecord
  def self.random
    order('RANDOM()').first.url
  end
end
