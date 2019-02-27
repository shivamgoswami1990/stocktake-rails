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
    cached_companies = Rails.cache.redis.get("companies")
    if cached_companies
      @companies = cached_companies

    else
      @companies = apply_scopes(Company).all
      Rails.cache.redis.set("companies", @companies.to_json)
    end

    render :json => @companies
  end

  # GET /companies/1
  def show
    cached_company = Rails.cache.redis.get("companies/" + params[:id].to_s)

    if cached_company
      @company = JSON.parse(cached_company)
    else
      @company = load_company
      Rails.cache.redis.set("companies/" + params[:id].to_s, @company.to_json)
    end

    render :json => @company
  end

  # GET /companies/1/last_created_invoice
  def last_created_invoice
    @company = load_company

    invoices = @company.invoices
    max_no = invoices.maximum('invoice_no_as_int')
    last_invoice = invoices.where(invoice_no_as_int: max_no)[0]

    # Get last ten invoice nos from the max invoice no
    five_recent_invoices = []
    i = 0
    while (i >= 0)
      current_invoice = invoices.where(invoice_no_as_int: (max_no-i))[0]
      if current_invoice.present?
        five_recent_invoices.push({
            'invoice_no': current_invoice[:invoice_no],
            'invoice_date': current_invoice[:invoice_date],
                                 })
      end

      if five_recent_invoices.length == 5
        break
      end
      i = i + 1
    end

    if @company
      render :json => {
          invoice_no: last_invoice[:invoice_no],
          invoice_date: last_invoice[:invoice_date],
          five_recent_invoices: five_recent_invoices
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
