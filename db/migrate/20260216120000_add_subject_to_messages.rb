class AddSubjectToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :subject, :string, null: false, default: "Χωρίς θέμα"
  end
end
