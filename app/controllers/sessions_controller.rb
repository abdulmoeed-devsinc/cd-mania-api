class SessionsController < Devise::SessionsController
  respond_to :json
  before_action :authenticate_user!, except: [:create]
  before_action :sign_in_params, only: :create
  before_action :set_user, only: :create

  def create
    if @user.valid_password?(sign_in_params[:password])
      sign_out_all_scopes
      sign_in "user", @user
      token = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil)
      render json: {messages: 'Signed In Successfully',is_success: true,data: {user: @user}, token: token[0] } ,status: :ok
    else
      render json: {messages: 'Signed In Failed - Unauthorized',is_success: false,data: {}}, status: :unauthorized
    end
  end

  private
  def sign_in_params
    params.require(:sign_in).permit :email, :password
  end

  def set_user
    @user = User.find_for_database_authentication(email: sign_in_params[:email])
    if @user
      return @user
    else
      render json: {messages: "Cannot get User",is_success: false,data: {}}, status: :failure
    end
  end

  def respond_to_on_destroy
      head :ok
  end
end
