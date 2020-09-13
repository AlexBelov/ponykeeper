class Image < ApplicationRecord
  enum entity: [:drink, :book]

  def self.random(image_types = entities.values)
    where(entity: image_types).all.sample.try(:url)
  end
end
