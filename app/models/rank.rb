class Rank < ApplicationRecord
  enum entity: [:drink, :book]
  has_and_belongs_to_many :users

  def self.check_for_ranks(user)
    drinks = user.drinks.count
    books = user.books_users.where(finished: true).count
    drink_ranks = Rank.where(entity: :drink).
      where('threshold < ?', drinks).
      filter{|r| !user.ranks.where(id: r.id).present?}
    book_ranks = Rank.where(entity: :book).
      where('threshold < ?', books).
      filter{|r| !user.ranks.where(id: r.id).present?}
    user.ranks << [drink_ranks + book_ranks] if [drink_ranks + book_ranks].present?
    drink_ranks + book_ranks
  end

  def response(user)
    message = Message.find_by(slug: 'rank')
    return unless message.present?
    response = message.interpolate({full_name: user.full_name, name: name})
  end
end
