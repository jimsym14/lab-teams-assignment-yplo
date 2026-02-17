class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :student_id])
		devise_parameter_sanitizer.permit(:account_update, keys: [:name, :student_id])
	end
end
