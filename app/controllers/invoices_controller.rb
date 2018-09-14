class InvoicesController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb

  before_action :authenticate_user!
  before_action :load_invoice, only: [:show, :edit, :update, :destroy]


  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  InvoicesController.new.scope_initialize(InvoicesController, Invoice)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /invoices
  def index
    @invoices = apply_scopes(Invoice).all
    render :json => @invoices.order(created_at: :desc)
  end

  # GET /recent_invoices
  def recent_invoices
    # Return last k invoices based on query parameters
    k = 5
    by_user_id = params[:by_user_id]
    by_not_user_id = params[:by_not_user_id]

    # Return invoices based on query params
    if by_user_id
      if User.exists?(by_user_id)
        user = User.find(by_user_id)
        render :json => user.invoices.order(created_at: :desc).limit(k)
      else
        render :json => {message: 'User does not exist'}, status: :not_found
      end
    elsif by_not_user_id
      render :json => Invoice.where.not(user_id: by_not_user_id).order(created_at: :desc).limit(k)
    else
      render :json => Invoice.all.order(created_at: :desc).limit(k)
    end
  end

  # GET /invoices_between?from_date=date1&to_date=date2
  def invoices_between
    from_date = params[:from_date]
    to_date = params[:to_date]

    render :json => Invoice.where('created_at BETWEEN ? AND ? AND invoice_status = 1',
                                  Time.parse(from_date).utc.beginning_of_day + 86400,
                                  Time.parse(to_date).utc.end_of_day + 86400).order(invoice_no_as_int: :desc)
  end

  # GET /invoices/1
  def show
    cached_invoice = Rails.cache.redis.get("invoices/" + params[:id].to_s)

    if cached_invoice
      @invoice = JSON.parse(cached_invoice)
    else
      @invoice = load_invoice
      Rails.cache.redis.set("invoices/" + params[:id].to_s, @invoice.to_json)
    end

    render :json => @invoice
  end

  # GET /previous_and_next_invoice?for_invoice_no_as_int=1&company_id=1
  def previous_and_next_invoice
    if params[:for_invoice_no_as_int] and params[:company_id]
      render :json => {
          :'previous_invoice' => Invoice.where('invoice_no_as_int < ? AND company_id = ?',
                                               params[:for_invoice_no_as_int],
                                               params[:company_id]).order('invoice_no_as_int DESC').first,
          :'next_invoice' => Invoice.where('invoice_no_as_int > ? AND company_id = ?',
                                           params[:for_invoice_no_as_int],
                                           params[:company_id]).order('invoice_no_as_int ASC').first
      }
    else
      render json: {:'data' => 'for_invoice_no_as_int and company_id need to be present in the request'}, status: 400
    end

  end

  # GET /previous_ordered_item_search_for_customer?customer_id=1&item_name=Amber
  def previous_ordered_item_search_for_customer
    if params[:customer_id] and params[:item_name]

      results = Customer.find(params[:customer_id]).invoices.search_by_item_array(params[:item_name]).pluck(:item_array, :created_at)

      ordered_items = []

      # Sort the unique items
      results.each do |result|
        item_array = result[0]
        created_at = result[1]

        item_array.each do |item|

          # Check if item name is not empty
          if item['item_name'].length > 0
            item['created_at'] = created_at
            ordered_items.push(item)
          end
        end
      end

      render :json => ordered_items
    else
      render json: {:'data' => 'customer_id and item_name need to be present in the request'}, status: 400
    end
  end

  # GET /past_invoices?search_term=Jane
  def past_invoices
    if params[:search_term]

      results = Invoice.search_by_company_customer_id(params[:search_term])
      render :json => results
    else
      render json: {:'data' => 'search_term need to be present in the request'}, status: 400
    end
  end

  # GET /historical_data
  def historical_data
    if params[:by_month].eql?('true')
      render :json => Invoice.all.group_by{ |t| t.created_at.month }
    end
  end

  # POST /invoices
  def create

    # Check if invoice no is unique for a company
    if invoice_params[:invoice_no]

      # Search invoice table for this company_id & invoice no for unique invoice nos for a company
      if (Invoice.where('company_id = ? AND invoice_no = ?', invoice_params[:company_id],
                        invoice_params[:invoice_no].to_s).count).eql?(0)
        @invoice = Invoice.create(invoice_params)
        if @invoice.save
          StatisticCalculationJob.perform_later
          NotificationJob.perform_later('invoice', 'created', @invoice.id, current_user)
          render :json => @invoice
        else
          render json: :BadRequest, status: 400
        end
      else
        render json: {:'status' => 'Failed', :'data' => 'Invoice exists for this company'}, status: 400
      end

    end
  end

  # PATCH/PUT /invoices/1
  def update
    if @invoice.update(invoice_params)
      StatisticCalculationJob.perform_later
      NotificationJob.perform_later('invoice', 'updated', @invoice.id, current_user)
      render :json => @invoice
    else
      render json: :BadRequest, status: 400
    end
  end

  # DELETE /invoices/1
  def destroy
    @invoice.destroy
    render :json => @invoices
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def invoice_params
    params.require(:invoice).permit!
  end
end
