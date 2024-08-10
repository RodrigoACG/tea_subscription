class Subscription < ApplicationRecord
  validates :title, :price, :frequency, :status, presence: :true

  # enum status: { cancelled: 0, active: 1 }
  enum status: ["cancelled", "active"]
  belongs_to :customer
  has_many :tea_subs
  has_many :teas, through: :tea_subs
end
