class CreateGroupChatMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :group_chat_memberships do |t|
      t.references :group_chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :group_chat_memberships, [:group_chat_id, :user_id], unique: true, name: "index_group_chat_memberships_on_group_and_user"
  end
end
