class Todo < ApplicationRecord
  belongs_to :user
  has_many :todo_items, dependent: :destroy

  validates :title, presence: true
  # Ο τίτλος να μην είναι υπερβολικά μικρός
  validates :title, length: { minimum: 3, message: "Ο τίτλος της εργασίας πρέπει να έχει τουλάχιστον 3 χαρακτήρες" }
end
