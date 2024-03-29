class User < ApplicationRecord
  has_secure_password
  validates :email, uniqueness: { case_sensitive: false }
  has_many :plans
  has_many :tickets, through: :plans
end
