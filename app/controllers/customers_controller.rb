class CustomersController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb


  before_action :authenticate_user!
  before_action :load_customer, only: [:show, :edit, :update, :destroy, :last_created_invoice,
                                       :all_ordered_items, :invoice_sample_comments]
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
    last_invoice = @customer.invoices.last
    render :json => {
        invoice_no: last_invoice[:invoice_no],
        invoice_date: last_invoice[:invoice_date],
        company_details: last_invoice[:company_details]
    } unless @customer.invoices.empty?
  end

  # GET /customers/1/all_ordered_items
  def all_ordered_items
    @customer = load_customer
    results = @customer.invoices.where(invoice_status: 1).order('created_at DESC').pluck(:item_array, :created_at)

    ordered_items = []

    # Sort the unique items
    results.each do |result|
      item_array = result[0]
      created_at = result[1]

      item_array.each do |item|

        # Check if item name is not empty
        if item['item_name'].length > 0
          # Check if ordered items length is less than 5
          item['created_at'] = created_at
          ordered_items.push(item)
        end
      end
    end

    render :json => ordered_items
  end

  # GET /customers/1/invoice_sample_comments
  def invoice_sample_comments
    @customer = load_customer
    invoices = @customer.invoices.where.not('sample_comments' => nil).pluck(:sample_comments, :invoice_date)

    render :json => invoices
  end

  # POST /customers
  def create
    # If GSTIN no exists, check if it's unique
    valid_params = false

    if customer_params[:gstin_no].empty?
      # If GST no is empty, create the customer
      valid_params = true
    else
      # If GST no exists, then check if unique before creating
      if Customer.find_by_gstin_no(customer_params[:gstin_no])
        valid_params = false
      else
        valid_params = true
      end
    end


    # Create customer
    if valid_params
      @customer = Customer.new(customer_params)
      if @customer.save
        NotificationJob.perform_later('customer', 'created', @customer.id, current_user)
        render :json => @customer, status: 201
      else
        render json: :BadRequest, status: 400
      end
    else
      render json: :Conflict, status: 409
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      NotificationJob.perform_later('customer', 'updated', @customer.id, current_user)
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
