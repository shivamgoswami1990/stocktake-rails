class CustomersController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb


  before_action :authenticate_user!
  before_action :load_customer, only: [:show, :edit, :update, :destroy, :last_created_invoice,
                                       :all_ordered_items, :invoice_sample_comments, :invoice_count]
  require "json"

  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  CustomersController.new.scope_initialize(CustomersController, Customer)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /customers
  # 10 records per page by default. Set in the model.
  def index
    if params[:search_term]
      customers = Customer.search_customer(params[:search_term])
    else
      customers = apply_scopes(Customer).all
    end

    if params[:page_no]
      result = customers.page(params[:page_no])

      # If financial year params, then change invoice count to financial year
      if params[:financial_year]
        result.each do |customer|
          customer.invoice_count = customer.invoices.where(financial_year: params[:financial_year]).count
        end
      end
    else
      result = customers
    end
    render :json => {
        data: result,
        total_records: Customer.count
    }
  end

  # GET /customers/1
  def show
    @customer = load_customer
    render :json => @customer
  end

  # GET /customers/1/last_created_invoice
  def last_created_invoice
    invoices = @customer.invoices.where(financial_year: params[:financial_year])

    # Get the last created invoice
    last_invoice_by_created_at = invoices.last

    # Get the invoice by max invoice no
    max_no = invoices.maximum('invoice_no_as_int')
    last_invoice_by_invoice_no = invoices.where(invoice_no_as_int: max_no)[0]

    render :json => {
        created_at: {
            invoice_no: last_invoice_by_created_at.nil? ? '': last_invoice_by_created_at[:invoice_no],
            invoice_date: last_invoice_by_created_at.nil? ? '': last_invoice_by_created_at[:invoice_date],
            company_details: last_invoice_by_created_at.nil? ? {}: last_invoice_by_created_at[:company_details]
        },
        invoice_no: {
            invoice_no: last_invoice_by_invoice_no.nil? ? '': last_invoice_by_invoice_no[:invoice_no],
            invoice_date: last_invoice_by_invoice_no.nil? ? '': last_invoice_by_invoice_no[:invoice_date],
            company_details: last_invoice_by_invoice_no.nil? ? {}: last_invoice_by_invoice_no[:company_details]
        }
    }
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

  # GET /customers/1/invoice_count
  def invoice_count
    render :json => {
        invoice_count: @customer.invoices.count
    }
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
