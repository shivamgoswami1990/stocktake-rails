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

    if @company
      render :json => {
          invoice_no: @company.invoices.last[:invoice_no],
          invoice_date: @company.invoices.last[:invoice_date]
      } unless @company.invoices.empty?
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
