class AddDeliveryModeToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :delivery_mode, :string
    add_index :messages, :delivery_mode
  end
end
