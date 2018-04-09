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
    render :json => @invoices
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

    render :json => Invoice.where("created_at >= ? AND created_at <= ?", from_date, to_date)
  end

  # GET /invoices/1
  def show
    @invoice = load_invoice
    render :json => @invoice
  end

  # POST /invoices
  def create

    # Check if invoice no is unique for a company
    if invoice_params[:invoice_no]

      # Search invoice table for this company_id & invoice no
      if (Invoice.where('company_id = ? AND invoice_no = ?', invoice_params[:company_id], invoice_params[:invoice_no].to_s).count).eql?(0)
        @invoice = Invoice.create(invoice_params)
        if @invoice.save
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
