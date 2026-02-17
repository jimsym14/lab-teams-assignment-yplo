class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_secure_token :api_token

  has_many :posts, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :contact_users, through: :contacts, source: :contact_user

  has_many :reverse_contacts,
           class_name: "Contact",
           foreign_key: :contact_user_id,
           dependent: :destroy
  has_many :followers, through: :reverse_contacts, source: :user

  has_many :sent_messages,
           class_name: "Message",
           foreign_key: :sender_id,
           dependent: :destroy
  has_many :received_messages,
           class_name: "Message",
           foreign_key: :recipient_id

  has_many :notifications
  has_many :todos, dependent: :destroy

  has_many :created_group_chats,
           class_name: "GroupChat",
           foreign_key: :creator_id,
           dependent: :destroy
  has_many :group_chat_memberships, dependent: :destroy
  has_many :group_chats, through: :group_chat_memberships

  validates :name, presence: true

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email
    if auth.info.name.present?
      user.name = auth.info.name
    else
      user.name = auth.info.email
    end
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.save
    user
  end
end
