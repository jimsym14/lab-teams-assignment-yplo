class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :contact_user, class_name: "User"

  validates :contact_user_id, uniqueness: { scope: :user_id }
  validate :different_user

  private

  def different_user
    return if user_id != contact_user_id

    errors.add(:contact_user_id, "δεν μπορείς να βάλεις τον εαυτό σου στις επαφές")
  end
end
