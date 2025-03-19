class User < ApplicationRecord
    has_many :reviews, dependent: :destroy
  
    validates :name, :email, presence: true
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  end
  