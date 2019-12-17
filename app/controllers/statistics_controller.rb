class StatisticsController < ApplicationController
  before_action :authenticate_user!

  #Initialise scopes using concerns
  StatisticsController.new.scope_initialize(StatisticsController, Statistic)

  # GET /statistics
  def index
    if read_from_cache("statistics")
      statistics = read_from_cache("statistics")
    else
      statistics = apply_scopes(Statistic).all
      write_to_cache("statistics", statistics)
    end
    render :json => statistics
  end

  public
  def refresh_statistics
    financial_year_list = Invoice.distinct.pluck(:financial_year)

    # Go through each unique financial year value & calculate stats
    # Statistic.delete_all
    financial_year_list.each do |financial_year|
      stats_for_financial_year(financial_year) unless financial_year.nil?
    end
  end

  def stats_for_financial_year(financial_year)
    total_revenue = 0
    total_taxable_value = 0
    total_tax = 0
    total_insurance = 0
    total_postage = 0
    total_discount = 0

    Invoice.where(financial_year: financial_year).pluck(:item_summary, :tax_summary).each do |invoice|
      invoice_item_summary = invoice[0]
      invoice_tax_summary = invoice[1]

      if (invoice_item_summary)
        total_revenue += invoice_item_summary['total_after_round_off'].to_f if invoice_item_summary['total_after_round_off'].present?
        total_insurance += invoice_item_summary['insurance_percentage_amount'].to_f if invoice_item_summary['insurance_percentage_amount'].present?
        total_postage += invoice_item_summary['postage_charge'].to_f if invoice_item_summary['postage_charge'].present?
        total_discount += invoice_item_summary['discount'].to_f if invoice_item_summary['discount'].present?
      end

      if (invoice_tax_summary)
        total_taxable_value += invoice_tax_summary['hsn_summary_total']['total_taxable_value'].to_f if invoice_tax_summary.present?
        total_tax += invoice_tax_summary['hsn_summary'][0]['total_tax_amount'].to_f if invoice_tax_summary['hsn_summary'].present?
      end

    end

    # Save these stats to the Statistics model. Check if an entry for the current financial year exists
    existing_stat = Statistic.find_by_financial_year financial_year

    if existing_stat.nil?
      Statistic.new(total_revenue: total_revenue.to_f, total_taxable_value: total_taxable_value.to_f,
                       total_tax: total_tax.to_f, total_insurance: total_insurance.to_f, financial_year: financial_year,
                       total_postage: total_postage.to_f, total_discount: total_discount.to_f).save
    else
      existing_stat.update(total_revenue: total_revenue.to_f, total_taxable_value: total_taxable_value.to_f,
                    total_tax: total_tax.to_f, total_insurance: total_insurance.to_f, financial_year: financial_year,
                    total_postage: total_postage.to_f, total_discount: total_discount.to_f)
    end
  end
end
