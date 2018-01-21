class UsersController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb

  before_action :authenticate_user!
  before_action :load_user, only: [:show, :edit, :update, :destroy]


  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  UsersController.new.scope_initialize(UsersController, User)


  #//////////////////////////////////////////// REST API ///////////////////////////////////////////////////////////////
  # GET /users
  def index
    @users = apply_scopes(User).all
    render :json => @users
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
    else
      render json: :BadRequest, status: 400
    end
  end

  # DELETE /users/1
  def destroy
    @user.profile_image.destroy
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