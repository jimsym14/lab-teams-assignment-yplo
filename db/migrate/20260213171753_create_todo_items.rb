class CreateTodoItems < ActiveRecord::Migration[7.1]
  def change
    create_table :todo_items do |t|
      t.references :todo, null: false, foreign_key: true
      t.string :title
      t.boolean :done, default: false, null: false

      t.timestamps
    end
  end
end
