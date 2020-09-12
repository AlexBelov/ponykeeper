class Image < ApplicationRecord
  enum entity: [:drink, :book]

  def self.random(image_types = entities.values)
    where(entity: image_types).order('RANDOM()').first.try(:url)
  end
end
