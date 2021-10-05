class User < ApplicationRecord
  attr_accessor :remember_token
  before_save :downcase_email

  validates :name, presence: true, length: {maximum: Settings.length.digit_50}
  validates :email, presence: true,
            length: {maximum: Settings.length.digit_255},
            format: {with: Settings.email_regrex}, uniqueness: true
  validates :password, presence: true,
            length: {minimum: Settings.length.digit_6}
  has_secure_password
  ATR_PERMIT = %i(name email password password_confirmation).freeze

  def authenticated? remember_token
    return unless remember_digest

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
