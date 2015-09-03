class AccountingController < ApplicationController
  def index
    @periods = Element.where(kind: 'financial').order(:rank)
    if params[:period].present?
      @period =  params[:period]
    else
      @period = 'FQ to date'
    end

    case @period
      when 'FY to date'
        period = fy_to_date
        params[:account_date_gteq] = period[0]
        params[:account_date_lteq] = period[1]
      when 'FQ to date'
        period = fq_to_date
        params[:account_date_gteq] = period[0]
        params[:account_date_lteq] = period[1]
      when 'Last FY'
        period = last_fy
        params[:account_date_gteq] = period[0]
        params[:account_date_lteq] = period[1]
      when 'Last FQ'
        period = last_fq
        params[:account_date_gteq] = period[0]
        params[:account_date_lteq] = period[1]
      else
        params[:account_date_gteq] = ''
        params[:account_date_lteq] = ''
    end
    @start = params[:account_date_gteq]
    @stop = params[:account_date_lteq]
    @stop = nil if @start && @stop && @start > @stop
  end
end
