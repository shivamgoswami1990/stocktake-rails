class CompaniesController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb

  before_action :authenticate_user!
  before_action :load_company, only: [:show, :edit, :update, :destroy, :last_created_invoice]


  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  CompaniesController.new.scope_initialize(CompaniesController, Company)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /companies
  def index
    @companies = apply_scopes(Company).all
    render :json => @companies
  end

  # GET /companies/1
  def show
    @company = load_company
    render :json => @company
  end

  # GET /companies/1/last_created_invoice
  def last_created_invoice
    @company = load_company

    invoices = @company.invoices.where(financial_year: params[:financial_year]).order('invoice_no_as_int DESC')
                   .limit(10).select(:id, :invoice_no, :invoice_date, :user_id, :company_id, :customer_id)

    last_invoice = {}
    recent_invoices = []
    if invoices.count > 0
      last_invoice = invoices[0]

      invoices.each do |invoice|
        recent_invoices.push({
            'invoice_no': invoice.invoice_no,
            'invoice_date': invoice.invoice_date
                             })
      end
    end

    if @company
      render :json => {
          invoice_no: last_invoice[:invoice_no],
          invoice_date: last_invoice[:invoice_date],
          five_recent_invoices: recent_invoices
      } unless invoices.empty?
    else
      render :json => {}, status: 404
    end
  end

  # POST /companies
  def create
    @company = Company.new(company_params)
    if @company.save
      render :json => @company
    else
      render json: :BadRequest, status: 400
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      render :json => @company
    else
      render json: :BadRequest, status: 400
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    render :json => @companies
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_company
    @company = Company.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit!
  end

end
