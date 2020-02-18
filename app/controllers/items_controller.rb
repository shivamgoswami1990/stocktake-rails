class ItemsController < ApplicationController
  before_action :load_item, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

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
      if read_from_cache("items")
        items = read_from_cache("items")
      else
        items = apply_scopes(Item).all
        write_to_cache("items", items)
      end
    end

    if params[:page_no]
      result = pagy(items)
    else
      result = items
    end
    render :json => result
  end

  # GET /items/1
  def show
    @item = load_item
    render :json => @item
  end

  # POST /search_items
  def search_items
    render :json => Item.search_item(params[:search_term])
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
    if read_from_cache("invoices")
      @item = read_from_cache("invoices").find(params[:id])
    else
      @item = Item.find(params[:id])
    end
  end

  # Only allow a trusted parameter "white list" through.
  def item_params
    params.require(:item).permit!
  end
end