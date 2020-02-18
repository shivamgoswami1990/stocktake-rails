class OrderedItemsController < ApplicationController
  before_action :load_ordered_item, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  OrderedItemsController.new.scope_initialize(OrderedItemsController, OrderedItem)


  #//////////////////////////////////////////// REST API ///////////////////////////////////////////////////////////////
  # GET /ordered_items
  # No pagination on ordered items. Only search with scopes
  def index
    render :json => OrderedItem.where(customer_id: params[:customer_id]).order(item_name: :asc).order(order_date: :desc).group_by(&:name_key)
  end

  # GET /ordered_items/1
  def show
    @ordered_item = load_ordered_item
    render :json => @ordered_item
  end

  # GET /all_ordered_items
  def all_ordered_items
    render :json => OrderedItem.where(customer_id: params[:customer_id]).order(order_date: :desc)
  end

  # POST /search_ordered_items_by_name
  # ** Item name can have spaces which gets %20 char when using query params in  GET request
  def search_ordered_items_by_name
    ordered_items = []
    if params[:search_term] and params[:customer_id]
      ordered_items = OrderedItem.where(customer_id: params[:customer_id]).order(order_date: :desc).search_ordered_item(params[:search_term]).group_by(&:name_key)
    elsif params[:recent_items] and params[:customer_id]
      ordered_items = OrderedItem.where(customer_id: params[:customer_id]).order(order_date: :desc).limit(10).group_by(&:name_key)
    end

    render :json => ordered_items
  end

  # POST /ordered_items
  def create
    @ordered_item = OrderedItem.new(ordered_item_params)

    if @ordered_item.save
      render :json => @ordered_item
    else
      render json: :BadRequest, status: 400
    end
  end

  # PATCH/PUT /ordered_items/1
  def update
    if @ordered_item.update(ordered_item_params)
      render :json => @ordered_item
    else
      render json: :BadRequest, status: 400
    end
  end

  # DELETE /users/1
  def destroy
    @ordered_item.destroy
    render :json => {
        data: "Deleted successfully"
    }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_ordered_item
    @ordered_item = OrderedItem.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ordered_item_params
    params.require(:ordered_item).permit!
  end
end
