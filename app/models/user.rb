class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true, length: {maximum: Settings.length.digit_50}

  validates :email, presence: true,
            length: {maximum: Settings.length.digit_255},
            format: {with: Settings.email_regrex}, uniqueness: true
  validates :password, presence: true,
            length: {minimum: Settings.length.digit_6}
  has_secure_password

  private

  def downcase_email
    self.email = email.downcase
  end
end
