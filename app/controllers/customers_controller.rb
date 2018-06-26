class CustomersController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb

  before_action :authenticate_user!
  before_action :load_customer, only: [:show, :edit, :update, :destroy, :last_created_invoice, :last_five_ordered_items]
  require "json"

  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  CustomersController.new.scope_initialize(CustomersController, Customer)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /customers
  def index
    cached_customers = Rails.cache.redis.get("customers")
    if cached_customers
      @customers = cached_customers

    else
      @customers = apply_scopes(Customer).all
      Rails.cache.redis.set("customers", @customers.order('name ASC').to_json)
    end

    render :json => @customers
  end

  # GET /customers/1
  def show
    cached_customer = Rails.cache.redis.get("customers/" + params[:id].to_s)

    if cached_customer
      @customer = JSON.parse(cached_customer)
    else
      @customer = load_customer
      Rails.cache.redis.set("customers/" + params[:id].to_s, @customer.to_json)
    end

    render :json => @customer
  end

  # GET /customers/1/last_created_invoice
  def last_created_invoice
    @customer = load_customer
    render :json => {
        invoice_no: @customer.invoices.last[:invoice_no],
        invoice_date: @customer.invoices.last[:invoice_date],
        company_details: @customer.invoices.last[:company_details]
    } unless @customer.invoices.empty?
  end

  # GET /customers/1/last_five_ordered_items
  def last_five_ordered_items
    @customer = load_customer
    results = @customer.invoices.where(invoice_status: 1).order('created_at DESC').pluck(:item_array, :created_at)

    ordered_items = []

    # Sort the unique items
    results.each do |result|
      item_array = result[0]
      created_at = result[1]

      item_array.each do |item|

        # Check if the item_obj property exists
        if item.key?("item_obj")

          # Check if ordered items length is less than 5
          if ordered_items.length < 5
            item['created_at'] = created_at
            ordered_items.push(item)
          else
            break
          end
        end
      end
    end

    render :json => ordered_items
  end

  # POST /customers
  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      render :json => @customer
    else
      render json: :BadRequest, status: 400
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      ActionCable.server.broadcast('invoices', {'notification_type' => 'edited_customer',
                                                'name' => @customer.name,
                                                'last_edited_by_id' => @customer.last_edited_by_id,
                                                'last_edited_by_details' => User.find(@customer.last_edited_by_id)
      })
      render :json => @customer
    else
      render json: :BadRequest, status: 400
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy
    render :json => @customers
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_customer
    @customer = Customer.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def customer_params
    params.require(:customer).permit!
  end
end
