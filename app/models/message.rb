class Message < ApplicationRecord
  attr_accessor :recipient_ids

  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User", optional: true
  belongs_to :group_chat, optional: true
  has_many :notifications, dependent: :destroy

  validates :subject, presence: true
  validates :body, presence: true
  validate :direct_message_must_have_recipient
  validate :group_message_must_have_group_chat

  after_create :create_recipient_notification

  private

  def create_recipient_notification
    if delivery_mode.to_s == "group" && group_chat.present?
      group_chat.members.where.not(id: sender_id).find_each do |member|
        Notification.create!(user: member, message: self, kind: "new_message")
      end
    elsif recipient.present?
      Notification.create!(user: recipient, message: self, kind: "new_message")
    end
  end

  def direct_message_must_have_recipient
    return if delivery_mode.to_s == "group"
    return if recipient.present?

    errors.add(:recipient_id, "δεν μπορεί να είναι κενό")
  end

  def group_message_must_have_group_chat
    return unless delivery_mode.to_s == "group"
    return if group_chat.present?

    errors.add(:group_chat_id, "δεν μπορεί να είναι κενό")
  end
end
