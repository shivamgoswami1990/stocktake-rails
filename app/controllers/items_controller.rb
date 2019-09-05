class ItemsController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb
  before_action :authenticate_user!
  before_action :load_item, only: [:show, :edit, :update, :destroy]
  require "json"

  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  ItemsController.new.scope_initialize(ItemsController, Item)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /items
  # 10 records per page by default. Set in the model.
  def index
    if params[:search_term]
      items = Item.search_item(params[:search_term])
    else
      items = apply_scopes(Item).all
    end

    if params[:page_no]
      result = items.page(params[:page_no])
    else
      result = items
    end
    render :json => {
        data: result,
        total_records: Item.count
    }
  end

  # GET /items/1
  def show
    @item = load_item
    render :json => @item
  end

  # POST /items
  def create
    @item = Item.new(item_params)
    if @item.save
      render :json => @item
    else
      render json: :BadRequest, status: 400
    end
  end

  # PATCH/PUT /items/1
  def update
    if @item.update(item_params)
      render :json => @item
    else
      render json: :BadRequest, status: 400
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy
    render :json => @items
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_item
    @item = Item.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def item_params
    params.require(:item).permit!
  end
end