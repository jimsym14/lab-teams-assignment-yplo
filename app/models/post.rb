class Post < ApplicationRecord
  belongs_to :user

  validates :title, :category, presence: true

  scope :search, ->(term) do
    return all if term.blank?

    query = "%#{sanitize_sql_like(term.to_s.strip)}%"
    where("title LIKE :q OR body LIKE :q OR category LIKE :q", q: query)
  end
end
