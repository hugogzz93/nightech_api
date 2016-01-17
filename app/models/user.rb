class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  	devise :database_authenticatable, :registerable,
        	:recoverable, :rememberable, :trackable, :validatable

	validates :auth_token, uniqueness: true
	before_create :generate_authentication_token!

	enum credentials: [:coordinator, :administrator, :super]

	def generate_authentication_token!
    begin
      	self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  # def credentials_to_i
    # self.class.credentials[self.credentials]
  # end

  def can_create?(user)
    self.outranks?(user)
  end

  def outranks?(user)
    # return true if User.credentials[user_attributes[:credentials]] < self.class.credentials[credentials]
    # return false
    return true if user.class.credentials[user.credentials] < self.class.credentials[credentials]
    return false
  end

end
