class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  scope :newest, ->{order created_at: :desc}
  validates :content, presence: true,
            length: {maximum: Settings.length.digit_140}
end
