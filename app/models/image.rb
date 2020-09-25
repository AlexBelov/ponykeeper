class Image < ApplicationRecord
  def self.random
    all.sample.try(:url)
  end

  rails_admin do
    show do
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
