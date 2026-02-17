class AddGroupChatToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference :messages, :group_chat, foreign_key: true
    change_column_null :messages, :recipient_id, true
  end
end
