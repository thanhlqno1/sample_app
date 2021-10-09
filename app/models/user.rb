class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: Settings.length.digit_50}
  validates :email, presence: true,
            length: {maximum: Settings.length.digit_255},
            format: {with: Settings.email_regrex}, uniqueness: true
  validates :password, presence: true, allow_nil: true,
            length: {minimum: Settings.length.digit_6}
  has_secure_password
  ATR_PERMIT = %i(name email password password_confirmation).freeze

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return unless digest

    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
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

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
