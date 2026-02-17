class TodoItem < ApplicationRecord
  belongs_to :todo

  validates :title, presence: true
end
