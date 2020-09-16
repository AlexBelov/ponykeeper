class BooksUser < ApplicationRecord
  belongs_to :user
  belongs_to :book

  after_save :recalculate_user_score

  def recalculate_user_score
    user.update(book_score: BooksUser.where(user_id: user_id, finished: true).count)
  end
end