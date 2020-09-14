class Image < ApplicationRecord
  enum entity: [:drink, :book]

  def self.random(image_types = entities.values)
    where(entity: image_types).all.sample.try(:url)
  end

  rails_admin do
    show do
      field :entity
      field :url
      field :image do
        formatted_value do
          bindings[:view].tag(:img, { src: bindings[:object].url })
        end
      end
      include_all_fields
    end
  end
end
