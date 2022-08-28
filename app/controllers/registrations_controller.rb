class RegistrationsController < Devise::RegistrationsController

  after_action :send_email, only: :create

  # nested form in User>registration>new for an adopter or staff account
  # no attributes need to be accepted, just create new account with user_id reference
  def new
    build_resource({})
    resource.build_adopter_account
    resource.build_staff_account
    respond_with self.resource
  end

  private

  def sign_up_params
    params.require(:user).permit(:username,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :password,
                                 :signup_role,
                                 :password_confirmation,
                                 adopter_account_attributes: [:user_id],
                                 staff_account_attributes: [:user_id])
  end

  def account_update_params
    params.require(:user).permit(:username,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :password,
                                 :password_confirmation,
                                 :signup_role,
                                 :current_password)
  end

  # redirect new adopter users to adopter_profile#new
  def after_sign_up_path_for(resource)
    redirect_to new_profile_path
  end

  def after_sign_in_path_for(resource)
    redirect_to root_path
  end

  # currently not working with turbo stream - needs fixing
  def after_sign_out_path_for(resource)
    redirect_to root_path
  end

  # send mail after user is created
  def send_email
    if resource.adopter_account
      SignUpMailer.with(user: resource).adopter_welcome_email.deliver_now
    else
      SignUpMailer.with(user: resource).staff_welcome_email.deliver_now
      SignUpMailer.with(user: resource).admin_notification_new_staff.deliver_now
    end
  end
end

# see here for setting up redirects after login for each user type
# https://stackoverflow.com/questions/58296569/how-to-signup-in-two-different-pages-with-devise