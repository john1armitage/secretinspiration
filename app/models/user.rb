class User < ActiveRecord::Base
  has_secure_password

  has_many :carts

  has_many :pages

  validates_presence_of :password, :on => :create
  validates :email, uniqueness: true, presence: true
  validates :username, uniqueness: true
#  validates_email :email

  before_create { generate_token(:auth_token) }

  has_one :role

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    generate_token(:auth_token)
    save!
    UserMailer.password_reset(self).deliver
  end

end
