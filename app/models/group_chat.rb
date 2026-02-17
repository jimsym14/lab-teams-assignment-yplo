class GroupChat < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :group_chat_memberships, dependent: :destroy
  has_many :members, through: :group_chat_memberships, source: :user
  has_many :messages, dependent: :destroy

  validates :name, presence: true
end
