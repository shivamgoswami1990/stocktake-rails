class UsersController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb

  before_action :authenticate_user!
  before_action :load_user, only: [:show, :edit, :change_user_password, :update, :destroy]


  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  UsersController.new.scope_initialize(UsersController, User)


  #//////////////////////////////////////////// REST API ///////////////////////////////////////////////////////////////
  # GET /users
  # 10 records per page by default. Set in the model.
  def index
    if params[:search_term]
      users = User.search_user(params[:search_term])
    else
      users = apply_scopes(User).all
    end

    if params[:page_no]
      result = users.page(params[:page_no])

      # If financial year params, then change invoice count to financial year
      if params[:financial_year]
        result.each do |user|
          user.invoice_count = user.invoices.where(financial_year: params[:financial_year]).count
        end
      end
    else
      result = users
    end

    render :json => result
  end

  # GET /users/1
  def show
    @user = load_user
    render :json => @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render :json => @user
    else
      render json: :BadRequest, status: 400
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render :json => @user
      ActionCable.server.broadcast('user_info', {data: @user})
    else
      render json: :BadRequest, status: 400
    end
  end

  # PATCH/PUT /change_user_password?id=1&password=aus12345
  def change_user_password
    @user.password = params[:password]
    @user.save
    render :json => @user
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    render :json => @users
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit!
  end
end