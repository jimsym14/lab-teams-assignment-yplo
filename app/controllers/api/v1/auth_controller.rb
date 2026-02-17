class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_api_user!, only: [:signup, :login]

  def signup
    user = User.new(signup_params)

if user.save
      # Κάνουμε regenerate το token για να είμαστε σίγουροι ότι είναι φρέσκο
      user.regenerate_api_token
      render json: { token: user.api_token, user: { id: user.id, email: user.email, name: user.name } }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])

    # Έλεγχος αν υπάρχει ο χρήστης και αν το password είναι σωστό
    if user&.valid_password?(params[:password])
      user.regenerate_api_token
      render json: { token: user.api_token, user: { id: user.id, email: user.email, name: user.name } }, status: :ok
    else
      # Επιστρέφουμε 401 Unauthorized αν είναι λάθος τα στοιχεία
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def logout
    # Αλλάζουμε το token ώστε το παλιό να μην ισχύει πλέον
    @current_api_user.regenerate_api_token
    render json: { message: "Logged out" }, status: :ok
  end

  private

  def signup_params
    params.permit(:email, :password, :password_confirmation, :name, :student_id)
  end
end
