class TransportsController < ApplicationController
  before_action :load_transport, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  TransportsController.new.scope_initialize(TransportsController, Transport)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /transports
  # 10 records per page by default. Set in the model.
  def index
    if params[:search_term]
      transports = Transport.search_transport(params[:search_term])
    else
      if read_from_cache("transports")
        transports = read_from_cache("transports")
      else
        transports = apply_scopes(Transport).all
        write_to_cache("transports", transports)
      end
    end

    if params[:page_no]
      result = pagy(transports)
    else
      result = transports
    end
    render :json => result
  end

  # GET /transports/1
  def show
    @transport = load_transport
    render :json => @transport
  end

  # POST /transports
  def create
    @transport = Transport.new(transport_params)
    if @transport.save
      render :json => @transport
    else
      render json: :BadRequest, status: 400
    end
  end

  # PATCH/PUT /transports/1
  def update
    if @transport.update(transport_params)
      render :json => @transport
    else
      render json: :BadRequest, status: 400
    end
  end

  # DELETE /transports/1
  def destroy
    @transport.destroy
    render :json => @transports
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_transport
    if read_from_cache("transports")
      @transport = read_from_cache("transports").find(params[:id])
    else
      @transport = Transport.find(params[:id])
    end
  end

  # Only allow a trusted parameter "white list" through.
  def transport_params
    params.require(:transport).permit!
  end
end
