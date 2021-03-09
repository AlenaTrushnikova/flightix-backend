class Plan < ApplicationRecord
  belongs_to :user
  has_many :tickets, :dependent => :delete_all
end
