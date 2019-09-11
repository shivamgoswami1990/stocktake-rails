class InvoicesController < ApplicationController

  include HasScopeGenerator #located at /app/controllers/concerns/has_scope_generator.rb

  #before_action :authenticate_user!
  before_action :load_invoice, only: [:show, :update, :destroy]

  #//////////////////////////////////////////// SCOPES ////////////////////////////////////////////////////////////////

  #Initialise scopes using concerns
  InvoicesController.new.scope_initialize(InvoicesController, Invoice)

  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////

  # GET /invoices?financial_year=2018-19&page_no=4
  # 10 records per page by default. Set in the model.
  def index
    if params[:search_term]
      invoices = Invoice.search_by_company_customer_id(params[:search_term])
    else
      invoices = apply_scopes(Invoice).all
    end

    if params[:page_no]
      result = filter_invoices_fy(invoices.page(params[:page_no]).order(invoice_no_as_int: :desc))
    else
      result = filter_invoices_fy(invoices.order(invoice_no_as_int: :desc))
    end

    render :json => {
        data: result,
        total_pages: Invoice.count
    }
  end

  # GET /recent_invoices?by_user_id=2&financial_year=2019-20
  def recent_invoices
    # Return last k invoices based on query parameters
    k = 10
    by_user_id = params[:by_user_id]

    # Return invoices based on query params
    if by_user_id
      render :json => {
          yours: filter_invoices_fy(Invoice.where(user_id: by_user_id).order(created_at: :desc).limit(k)),
          others: filter_invoices_fy(Invoice.where.not(user_id: by_user_id).order(created_at: :desc).limit(k)),
      }
    else
      render :json => {message: 'User does not exist'}, status: :not_found
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
    @invoice = load_invoice
    render :json => @invoice
  end

  # GET /previous_and_next_invoice?for_invoice_no_as_int=1&company_id=1&financial_year=2019-20
  def previous_and_next_invoice
    if params[:for_invoice_no_as_int] and params[:company_id]
      render :json => {
          :'previous_invoice' => Invoice.where('invoice_no_as_int < ? AND company_id = ? AND financial_year = ?',
                                               params[:for_invoice_no_as_int],
                                               params[:company_id], params[:financial_year]).order('invoice_no_as_int DESC').first,
          :'next_invoice' => Invoice.where('invoice_no_as_int > ? AND company_id = ?  AND financial_year = ?',
                                           params[:for_invoice_no_as_int],
                                           params[:company_id], params[:financial_year]).order('invoice_no_as_int ASC').first
      }
    else
      render json: {:'data' => 'for_invoice_no_as_int and company_id need to be present in the request'}, status: 400
    end

  end

  # GET /previous_ordered_item_search_for_customer?customer_id=15&item_name=s&financial_year=2019-20
  def previous_ordered_item_search_for_customer
    if params[:customer_id] and params[:item_name]

      results = filter_invoices_fy(Customer.find(params[:customer_id]).invoices).search_by_item_array(params[:item_name]).pluck(:item_array, :created_at)

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

  # GET /past_invoices?search_term=Jane&financial_year=2018-19
  def past_invoices
    # Check if the parameter is an integer. If yes, then find by invoice_as_int. Else do a pg_search
    if params[:search_term]
      if is_number?( params[:search_term] )
        render :json => filter_invoices_fy(Invoice.where(invoice_no_as_int: params[:search_term].to_i))
      else
        results = filter_invoices_fy(Invoice.search_by_company_customer_id(params[:search_term]))
        render :json => results
      end
    else
      render json: {:'data' => 'search_term need to be present in the request'}, status: 400
    end
  end

  # GET /historical_data?date_list=[[2,2018],[4,2018]]
  def historical_data

    if params[:date_list]
      # Define constants before calculating count & sum for each company
      # 1. JK Delhi, 2. Mazic, 3. JK Loni

      # Convert date list to an array
      date_list = JSON.parse(params[:date_list])
      summary = []

      date_list.each do |date_item|
        invoices = Invoice.by_month(date_item[0], strict: true, field: 'invoice_date', year: date_item[1])

        first_company_count = 0
        second_company_count = 0
        third_company_count = 0
        first_company_revenue = 0.to_f
        second_company_revenue = 0.to_f
        third_company_revenue = 0.to_f

        # Go through all invoices for this month
        invoices.each do |invoice|
          if invoice.company_id.eql?(1)
            first_company_count += 1

            # Check if hsn_summary exists
            unless invoice[:tax_summary].eql?(nil)
              unless invoice[:tax_summary]['hsn_summary_total'].eql?(nil)
                first_company_revenue += invoice[:tax_summary]['hsn_summary_total']['total_taxable_value'].to_f
              end
            end
          end

          if invoice.company_id.eql?(2)
            second_company_count += 1

            # Check if hsn_summary exists
            unless invoice[:tax_summary].eql?(nil)
              unless invoice[:tax_summary]['hsn_summary_total'].eql?(nil)
                second_company_revenue += invoice[:tax_summary]['hsn_summary_total']['total_taxable_value'].to_f
              end
            end
          end

          if invoice.company_id.eql?(3)
            third_company_count += 1

            # Check if hsn_summary exists
            unless invoice[:tax_summary].eql?(nil)
              unless invoice[:tax_summary]['hsn_summary_total'].eql?(nil)
                third_company_revenue += invoice[:tax_summary]['hsn_summary_total']['total_taxable_value'].to_f
              end
            end
          end
        end

        # Append the results of this month to the summary
        summary.append({
            month: date_item[0],
            year: date_item[1],
            result: [
                {
                    'company_id': 1,
                    'invoice_count': first_company_count,
                    'invoice_revenue': first_company_revenue
                },
                {
                    'company_id': 2,
                    'invoice_count': second_company_count,
                    'invoice_revenue': second_company_revenue
                },
                {
                    'company_id': 3,
                    'invoice_count': third_company_count,
                    'invoice_revenue': third_company_revenue
                }
            ]})
      end

      render :json => summary
    end
  end

  # GET /hsn_summary_by_date?month=Jan
  def hsn_summary_by_date
    # Get invoices by month, fortnight or date and group taxable values by HSN no types
    invoices = Invoice.where(company_id: params[:company_id]).order(invoice_no_as_int: :asc)

    if params[:month]
      invoice_list = invoices.by_month(params[:month], strict: true, field: 'invoice_date', year: params[:year])
    elsif params[:quarter]
      invoice_list = invoices.by_quarter(params[:quarter], strict: true, field: 'invoice_date', year: params[:year])
    end

    # Only select the required columns
    invoice_list = invoice_list.select(:id, :invoice_no, :item_array, :tax_summary, :user_id, :company_id, :customer_id)

    grouped_hsn_summary = []
    invoice_list.each do |invoice|
      items = invoice['item_array']
      invoice['tax_summary']['hsn_summary'].each do |hsn_row|
        current_hsn = hsn_row['hsn'].to_s
        current_amount = hsn_row['amount'].nil? ? 0: hsn_row['amount'].to_f
        current_cgst_amount = hsn_row['cgst_amount'].nil? ? 0: hsn_row['cgst_amount'].to_f
        current_sgst_amount = hsn_row['sgst_amount'].nil? ? 0: hsn_row['sgst_amount'].to_f
        current_taxable_value = hsn_row['taxable_value']
        current_total_tax_amount = hsn_row['total_tax_amount']
        match_found = false
        match_index = nil

        # Add the first item to grouped_hsn_summary
        if grouped_hsn_summary.length.eql?0
          grouped_hsn_summary.append({
                                        hsn: current_hsn,
                                        amount: current_amount,
                                        cgst_amount: current_cgst_amount,
                                        sgst_amount: current_sgst_amount,
                                        taxable_value: current_taxable_value,
                                        total_tax_amount: current_total_tax_amount,
                                        quantity: calculate_total_quantity_by_hsn(items, current_hsn),
                                        invoices: [{id: invoice.id, invoice_no: invoice.invoice_no}]
                                    })
        else
          # Grouped_hsn_summary must have one or more items. Loop through & add with the matched HSN
          grouped_hsn_summary.each do |grouped_hsn_row|
            if grouped_hsn_row[:hsn].to_s.eql?(current_hsn)
              match_found = true
              match_index = grouped_hsn_summary.index{ |item| item[:hsn] == current_hsn }
              break
            end
          end

          if match_found
            # Add quantities together if a match was found
            grouped_hsn_summary[match_index][:amount] = grouped_hsn_summary[match_index][:amount].to_f + current_amount
            grouped_hsn_summary[match_index][:cgst_amount] = grouped_hsn_summary[match_index][:cgst_amount].to_f + current_cgst_amount
            grouped_hsn_summary[match_index][:sgst_amount] = grouped_hsn_summary[match_index][:sgst_amount].to_f + current_sgst_amount

            if grouped_hsn_summary[match_index][:taxable_value]
              grouped_hsn_summary[match_index][:taxable_value] = grouped_hsn_summary[match_index][:taxable_value].to_f + current_taxable_value
            end

            if grouped_hsn_summary[match_index][:total_tax_amount]
              grouped_hsn_summary[match_index][:total_tax_amount] = grouped_hsn_summary[match_index][:total_tax_amount].to_f + current_total_tax_amount
            end
            grouped_hsn_summary[match_index][:quantity] = grouped_hsn_summary[match_index][:quantity].to_f + calculate_total_quantity_by_hsn(items, grouped_hsn_summary[match_index][:hsn])
            grouped_hsn_summary[match_index][:invoices].append({id: invoice.id, invoice_no: invoice.invoice_no})

          else
            # Add a new record to the grouped_hsn_summary
            grouped_hsn_summary.append({
                                          hsn: current_hsn,
                                          amount: current_amount,
                                          cgst_amount: current_cgst_amount,
                                          sgst_amount: current_sgst_amount,
                                          taxable_value: current_taxable_value,
                                          total_tax_amount: current_total_tax_amount,
                                          quantity: calculate_total_quantity_by_hsn(items, current_hsn),
                                          invoices: [{id: invoice.id, invoice_no: invoice.invoice_no}]
                                      })
          end
        end


      end
    end

    render :json => grouped_hsn_summary
  end

  # GET /invoice_list?by_customer_id=1&month=2&year=2019
  def invoice_list
    # Filter invoices by date / month first
    invoices = []
    if params[:month] and params[:year]
      invoices = Invoice.by_month(params[:month], strict: true, field: 'invoice_date', year: params[:year])
    elsif params[:from_date] and params[:to_date]
      invoices = Invoice.between_times(params[:from_date].to_time, params[:to_date].to_time, strict: true, field: 'invoice_date')
    end

    # Filter invoices by company and/or customer
    if params[:by_company_id]
      if invoices.length.eql?0
        invoices = Invoice.where(company_id: params[:by_company_id])
      else
        invoices = invoices.where(company_id: params[:by_company_id])
      end
    end

    if params[:by_customer_id]
      if invoices.length.eql?0
        invoices = Invoice.where(customer_id: params[:by_customer_id])
      else
        invoices = invoices.where(customer_id: params[:by_customer_id])
      end
    end

    render :json => invoices.order(invoice_no_as_int: :desc)
  end

  # POST /invoices
  def create

    # Check if invoice no is unique for a company
    if invoice_params[:invoice_no]
      # Search invoice table for this company_id & invoice no for unique invoice nos for a company
      if (Invoice.where('company_id = ? AND invoice_no = ? AND financial_year = ?', invoice_params[:company_id],
                        invoice_params[:invoice_no].to_s, invoice_params[:financial_year]).count).eql?(0)
        @invoice = Invoice.create(invoice_params)
        if @invoice.save
          StatisticCalculationJob.perform_later(@invoice.financial_year)
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
      # Only generate notifications, if any attributes changed
      if @invoice.previous_changes.present?
        StatisticCalculationJob.perform_later(@invoice.financial_year)
        NotificationJob.perform_later('invoice', 'updated', @invoice.id, current_user)
      end

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

  # Financial year filter for the invoice
  def filter_invoices_fy(invoices)
    if params[:financial_year]
      return invoices.where(financial_year: params[:financial_year])
    else
      return invoices
    end
  end

  # Only allow a trusted parameter "white list" through.
  def invoice_params
    params.require(:invoice).permit!
  end

  # Return total quantity by HSN in item array
  def calculate_total_quantity_by_hsn(items, hsn)
    total_quantity = 0
    if items.length > 0
      items.each do |item|
        if item['item_hsn'].nil?.eql?(false )
          if item['item_hsn'].to_s.eql?(hsn)
            total_quantity = total_quantity.to_f + item['total_quantity'].to_f
          end
        end
      end
    end
    return total_quantity
  end

  # Check if string is a number
  def is_number? string
    true if Float(string) rescue false
  end
end
