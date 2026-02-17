class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_api_user!

  private

  def authenticate_api_user!
    # εδώ ελέγχουμε bearer token για να επιτρέπουμε πρόσβαση στο API
    token = bearer_token || request.headers["X-Api-Token"]
    @current_api_user = User.find_by(api_token: token)

    return if @current_api_user.present?

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def bearer_token
    request.headers["Authorization"].to_s.split(" ").last
  end
end
