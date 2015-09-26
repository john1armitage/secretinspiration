class DepreciationsController < ApplicationController

  def index
    @periods = Element.where(kind: 'financial').order(:rank)


    limit = params[:limit] || 100

    if params[:period].present?
      @period =  params[:period]
      case @period
        when 'FY to date'
          period = fy_to_date
          params[:q][:service_date_gteq] = period[0]
          params[:q][:service_date_lteq] = period[1]
        when 'FQ to date'
          period = fq_to_date
          params[:q][:service_date_gteq] = period[0]
          params[:q][:service_date_lteq] = period[1]
        when 'Last FY'
          period = last_fy
          params[:q][:service_date_gteq] = period[0]
          params[:q][:service_date_lteq] = period[1]
        when 'Last FQ'
          period = last_fq
          params[:q][:service_date_gteq] = period[0]
          params[:q][:service_date_lteq] = period[1]
        else
          params[:q][:service_date_gteq] = ''
          params[:q][:service_date_lteq] = ''
      end
    end
    @q = Depreciation.search(params[:q])
    if params[:q].present?
      @depreciations = @q.result(distinct: true).includes(:financial)
    else
      @depreciations = Depreciation.where('service_date >= ?', Time.now).includes(:financial)
    end
    @total = @depreciations.sum('allowable_cost_cents').to_d / 100
  end

end
