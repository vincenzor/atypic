class ApplicationController < ActionController::Base
  before_action :set_theme
  layout :set_layout
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_confirmation, unless: :devise_controller?

  def set_theme
    @theme = 'normal'
  end

  def set_layout
    if ['account', 'bulk_verifications', 'api_keys', 'subscriptions'].include?(controller_name) || request.path == '/users/edit'
      'logged'
    elsif devise_controller?
      'devise'
    else
      'marketing'
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || account_verify_path
  end

  def check_confirmation
    return unless user_signed_in?
    return unless current_user.account.plan.code.include?('free')
    redirect_to unconfirmed_path and return false if !current_user.confirmed?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :company_name])
  end
end
