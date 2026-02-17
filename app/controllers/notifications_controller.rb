class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.update(read_at: Time.now)
    redirect_to notifications_path, notice: "Η ειδοποίηση σημειώθηκε ως διαβασμένη."
  end
end
