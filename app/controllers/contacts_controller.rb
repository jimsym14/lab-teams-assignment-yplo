class ContactsController < ApplicationController
  before_action :authenticate_user!

  def index
    @contacts = current_user.contacts
  end

  def create
    contact_user_id = resolve_contact_user_id

    return redirect_to(contacts_path, alert: "Δεν βρέθηκε χρήστης με αυτό το email.") unless contact_user_id.present?

    @contact = current_user.contacts.new(contact_user_id: contact_user_id)

    if @contact.save
      redirect_to contacts_path, notice: "Η επαφή προστέθηκε."
    else
      redirect_to contacts_path, alert: "Υπήρξε πρόβλημα. Ελέγξτε τα στοιχεία σας."
    end
  end

  def destroy
    @contact = current_user.contacts.find(params[:id])
    @contact.destroy
    redirect_to contacts_path, notice: "Η επαφή αφαιρέθηκε."
  end

  private

  def contact_params
    params.require(:contact).permit(:contact_user_id, :email)
  end

  def resolve_contact_user_id
    submitted_id = contact_params[:contact_user_id]
    return submitted_id if submitted_id.present?

    email = contact_params[:email].to_s.strip.downcase
    return nil if email.blank?

    User.find_by(email: email)&.id
  end
end
