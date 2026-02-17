class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [:show]
  before_action :set_owned_message, only: [:edit, :update, :destroy]

  def index
    if panel_mode?
      prepare_panel_list_workspace
      render :panel_index
      return
    end

    @active_tab = params[:tab].to_s == "group" ? "group" : "personal"

    if @active_tab == "group"
      prepare_group_workspace
    else
      prepare_direct_workspace
    end
  end

  def groups
    redirect_to messages_path(tab: "group", group_chat_id: params[:group_chat_id], panel: params[:panel])
  end

  def chat
    @active_tab = params[:tab].to_s == "group" ? "group" : "personal"
    @conversation_messages = []

    if @active_tab == "group"
      prepare_group_chat_workspace
    else
      prepare_personal_chat_workspace
    end

    render :panel_chat
  end

  def show
    if @message.group_chat_id.present?
      redirect_to messages_path(tab: "group", group_chat_id: @message.group_chat_id, panel: params[:panel])
    else
      chat_user = conversation_user(@message)
      redirect_to messages_path(tab: "personal", chat_with: chat_user&.id, panel: params[:panel])
    end
  end

  def new
    @available_users = User.where.not(id: current_user.id).order(:email)
    @compose_mode = params[:mode].to_s == "group" ? "group" : "personal"
    @message = Message.new(sender: current_user, delivery_mode: @compose_mode, subject: "Chat")
  end

  def edit
  end

  def create
    if message_params[:group_chat_id].present?
      send_group_message
      return
    end

    delivery_mode = message_params[:delivery_mode].to_s
    delivery_mode = "personal" if delivery_mode.blank?

    if delivery_mode == "group"
      create_group_conversation
    else
      create_personal_message
    end
  end

  def update
    update_attrs = message_params.slice(:body)

    if @message.update(update_attrs)
      respond_to do |format|
        format.html { redirect_to @message, notice: "Το μήνυμα ενημερώθηκε." }
        format.json { render json: { id: @message.id, body: @message.body, updated_at: @message.updated_at.iso8601 } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to(request.referer.presence || messages_path, notice: "Το μήνυμα διαγράφηκε.") }
      format.json { head :no_content }
    end
  end

  private

  def set_message
    @message = accessible_messages.find(params[:id])
  end

  def set_owned_message
    @message = current_user.sent_messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:delivery_mode, :recipient_id, :subject, :body, :group_name, :group_chat_id, recipient_ids: [])
  end

  def panel_mode?
    params[:panel].to_s == "1"
  end

  def prepare_panel_list_workspace
    @active_tab = params[:tab].to_s == "group" ? "group" : "personal"
    @direct_conversations = build_direct_conversations.sort_by { |row| row[:last_message].created_at }.reverse
    @group_conversations = build_group_conversations.sort_by { |row| row[:last_message].created_at }.reverse
    @conversations = @active_tab == "group" ? @group_conversations : @direct_conversations
  end

  def prepare_personal_chat_workspace
    uid = params[:chat_with].to_i
    @active_chat_user = User.find_by(id: uid)

    unless @active_chat_user.present?
      @reply_message = Message.new(sender: current_user, delivery_mode: "personal", subject: "Chat")
      return
    end

    @conversation_messages = Message.where(group_chat_id: nil, sender: current_user, recipient: @active_chat_user)
                                   .or(Message.where(group_chat_id: nil, sender: @active_chat_user, recipient: current_user))
                                   .order(created_at: :asc)
    @reply_message = Message.new(sender: current_user, recipient: @active_chat_user, delivery_mode: "personal", subject: "Chat")
  end

  def prepare_group_chat_workspace
    gid = params[:group_chat_id].to_i
    @active_group_chat = current_user.group_chats.includes(:members).find_by(id: gid)

    unless @active_group_chat.present?
      @reply_message = Message.new(sender: current_user, delivery_mode: "group", subject: "Chat")
      return
    end

    @conversation_messages = @active_group_chat.messages.order(created_at: :asc)
    @reply_message = Message.new(sender: current_user, group_chat: @active_group_chat, delivery_mode: "group", subject: "Chat")
  end

  def message_content
    {
      subject: message_params[:subject].presence || "Chat",
      body: message_params[:body]
    }
  end

  def recipient_ids
    Array(message_params[:recipient_ids]).reject(&:blank?).map(&:to_i).uniq
  end

  def conversation_user(message)
    if message.sender_id == current_user.id
      message.recipient
    else
      message.sender
    end
  end

  def direct_messages_scope
    Message.where(group_chat_id: nil)
           .where(sender: current_user)
           .or(Message.where(group_chat_id: nil).where(recipient: current_user))
  end

  def group_messages_scope
    Message.joins(group_chat: :group_chat_memberships)
           .where(group_chat_memberships: { user_id: current_user.id })
           .where(delivery_mode: "group")
  end

  def accessible_messages
    Message.where(id: direct_messages_scope.select(:id))
           .or(Message.where(id: group_messages_scope.select(:id)))
  end

  def build_direct_conversations
    grouped = {}

    direct_messages_scope.order(created_at: :desc).each do |message|
      user = conversation_user(message)
      next unless user.present?
      next if grouped.key?(user.id)

      grouped[user.id] = {
        type: "direct",
        user: user,
        last_message: message
      }
    end

    grouped.values
  end

  def build_group_conversations
    grouped = {}

    current_user.group_chats.includes(:members).find_each do |group_chat|
      last_message = group_chat.messages.order(created_at: :desc).first
      next unless last_message.present?

      grouped[group_chat.id] = {
        type: "group",
        group_chat: group_chat,
        last_message: last_message
      }
    end

    grouped.values
  end

  def prepare_direct_workspace
    @direct_conversations = build_direct_conversations
    @conversations = @direct_conversations.sort_by { |row| row[:last_message].created_at }.reverse

    @active_chat_user = nil
    @active_conversation_type = "direct"

    if params[:chat_with].present?
      uid = params[:chat_with].to_i
      direct_row = @direct_conversations.find { |row| row[:user].id == uid }
      @active_chat_user = direct_row&.dig(:user)
    else
      first_row = @conversations.first
      @active_chat_user = first_row[:user] if first_row.present?
    end

    @conversation_messages = []

    if @active_chat_user.present?
      @conversation_messages = Message.where(group_chat_id: nil, sender: current_user, recipient: @active_chat_user)
                                   .or(Message.where(group_chat_id: nil, sender: @active_chat_user, recipient: current_user))
                                   .order(created_at: :asc)
      @reply_message = Message.new(sender: current_user, recipient: @active_chat_user, delivery_mode: "personal", subject: "Chat")
    else
      @reply_message = Message.new(sender: current_user, delivery_mode: "personal", subject: "Chat")
    end
  end

  def prepare_group_workspace
    @group_conversations = build_group_conversations
    @conversations = @group_conversations.sort_by { |row| row[:last_message].created_at }.reverse

    @active_group_chat = nil
    @active_conversation_type = "group"

    if params[:group_chat_id].present?
      gid = params[:group_chat_id].to_i
      group_row = @group_conversations.find { |row| row[:group_chat].id == gid }
      @active_group_chat = group_row&.dig(:group_chat)
    else
      first_row = @conversations.first
      @active_group_chat = first_row[:group_chat] if first_row.present?
    end

    @conversation_messages = []

    if @active_group_chat.present?
      @conversation_messages = @active_group_chat.messages.order(created_at: :asc)
      @reply_message = Message.new(sender: current_user, group_chat: @active_group_chat, delivery_mode: "group", subject: "Chat")
    else
      @reply_message = Message.new(sender: current_user, delivery_mode: "group", subject: "Chat")
    end
  end

  def create_personal_message
    @message = current_user.sent_messages.new(message_content.merge(recipient_id: message_params[:recipient_id]))
    @message.delivery_mode = "personal"

    if @message.save
      if panel_mode?
        redirect_to chat_messages_path(tab: "personal", chat_with: @message.recipient_id, panel: 1), notice: "Το μήνυμα στάλθηκε."
      else
        redirect_to messages_path(tab: "personal", chat_with: @message.recipient_id, panel: params[:panel]), notice: "Το μήνυμα στάλθηκε."
      end
    else
      @available_users = User.where.not(id: current_user.id).order(:email)
      @compose_mode = "personal"
      render :new, status: :unprocessable_entity
    end
  end

  def create_group_conversation
    members = recipient_ids
    group_name = message_params[:group_name].to_s.strip

    if group_name.blank?
      @message = current_user.sent_messages.new(message_content)
      @message.delivery_mode = "group"
      @message.errors.add(:base, "Συμπλήρωσε όνομα ομαδικής")
      @available_users = User.where.not(id: current_user.id).order(:email)
      @compose_mode = "group"
      render :new, status: :unprocessable_entity
      return
    end

    if members.blank?
      @message = current_user.sent_messages.new(message_content)
      @message.delivery_mode = "group"
      @message.errors.add(:base, "Επίλεξε τουλάχιστον ένα μέλος ομάδας")
      @available_users = User.where.not(id: current_user.id).order(:email)
      @compose_mode = "group"
      render :new, status: :unprocessable_entity
      return
    end

    group_chat = GroupChat.new(name: group_name, creator: current_user)

    unless group_chat.save
      @message = current_user.sent_messages.new(message_content)
      @message.delivery_mode = "group"
      @message.errors.add(:base, "Δεν ήταν δυνατή η δημιουργία ομαδικής")
      @available_users = User.where.not(id: current_user.id).order(:email)
      @compose_mode = "group"
      render :new, status: :unprocessable_entity
      return
    end

    membership_ids = members.dup
    membership_ids << current_user.id unless membership_ids.include?(current_user.id)
    membership_ids.each do |uid|
      GroupChatMembership.find_or_create_by(group_chat: group_chat, user_id: uid)
    end

    first_message = current_user.sent_messages.new(message_content)
    first_message.delivery_mode = "group"
    first_message.group_chat = group_chat

    if first_message.save
      if panel_mode?
        redirect_to chat_messages_path(tab: "group", group_chat_id: group_chat.id, panel: 1), notice: "Η ομαδική συνομιλία δημιουργήθηκε."
      else
        redirect_to messages_path(tab: "group", group_chat_id: group_chat.id, panel: params[:panel]), notice: "Η ομαδική συνομιλία δημιουργήθηκε."
      end
    else
      group_chat.destroy
      @message = first_message
      @available_users = User.where.not(id: current_user.id).order(:email)
      @compose_mode = "group"
      render :new, status: :unprocessable_entity
    end
  end

  def send_group_message
    group_chat = current_user.group_chats.find_by(id: message_params[:group_chat_id])

    unless group_chat.present?
      redirect_to messages_path(tab: "group", panel: params[:panel]), alert: "Η ομαδική συνομιλία δεν βρέθηκε."
      return
    end

    message = current_user.sent_messages.new(message_content)
    message.delivery_mode = "group"
    message.group_chat = group_chat

    if message.save
      if panel_mode?
        redirect_to chat_messages_path(tab: "group", group_chat_id: group_chat.id, panel: 1), notice: "Το μήνυμα στάλθηκε."
      else
        redirect_to messages_path(tab: "group", group_chat_id: group_chat.id, panel: params[:panel]), notice: "Το μήνυμα στάλθηκε."
      end
    else
      prepare_group_workspace
      @active_tab = "group"
      @active_group_chat = group_chat
      @active_conversation_type = "group"
      @conversation_messages = group_chat.messages.order(created_at: :asc)
      @reply_message = message
      render :index, status: :unprocessable_entity
    end
  end
end
