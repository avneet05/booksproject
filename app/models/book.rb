class Book < ApplicationRecord
  belongs_to :author
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres
  has_many :reviews, dependent: :destroy

  validates :title, :average_rating, :isbn, :language_code, :num_pages, presence: true
  validates :isbn, uniqueness: true
  validates :average_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
end
