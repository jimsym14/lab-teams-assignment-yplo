class GroupChatMembership < ApplicationRecord
  belongs_to :group_chat
  belongs_to :user

  validates :user_id, uniqueness: { scope: :group_chat_id }
end
