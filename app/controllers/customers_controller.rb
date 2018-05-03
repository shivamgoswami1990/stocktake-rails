class CustomersController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb

  before_action :authenticate_user!
  before_action :load_customer, only: [:show, :edit, :update, :destroy, :last_created_invoice]
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
        invoice_date: @customer.invoices.last[:invoice_date]
    } unless @customer.invoices.empty?
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
