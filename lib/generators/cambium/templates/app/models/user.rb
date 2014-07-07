class User < ActiveRecord::Base

  # ------------------------------------------ Devise

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :omniauthable, :confirmable, :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, 
         :validatable

  # ------------------------------------------ Scopes

  scope :admins, -> { where(:is_admin => true) }

end
