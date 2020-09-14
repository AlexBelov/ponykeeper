class DrinksUser < ApplicationRecord
  belongs_to :user
  belongs_to :drink

  rails_admin do
    list do
      field :id
      field :user
      field :drink
      field :abv
      field :volume
      include_all_fields
    end
  end
end
