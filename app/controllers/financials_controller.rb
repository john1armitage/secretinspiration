class FinancialsController < ApplicationController
  before_action :set_financial, only: [:show, :edit, :update, :destroy]

  # GET /transactions
  # GET /transactions.json
  def index
    #@financials = Financial.all

    @refs = get_entity_refs
    @suppliers = get_entity_suppliers
    @employees = get_entity_employees
    @banks = get_banks
    @target_banks = get_target_banks
    @classes = get_classes

    #Note: HACK TO ALLOW Employee & Supplier & Bank Search - misuses classification & summary
    if params[:q].present?
      @ref_bank = params[:q][:bank_eq]
      @class = params[:q][:classification_eq]
      if !params[:q][:mandate_eq].blank?
        @target_bank = params[:q][:entity_id_eq] = params[:q][:mandate_eq]
        params[:q][:entity_eq] = 'Bank'
      elsif !params[:q][:summary_eq].blank?
        params[:q][:entity_ref_eq] = params[:q][:summary_eq]
        params[:q][:entity_eq] = 'Employee'
        @employee = params[:q][:summary_eq]
        params[:q].delete :entity_id_eq
      elsif !params[:q][:entity_id_eq].blank?
        @supplier_id = params[:q][:entity_id_eq].to_i #= params[:q][:entity_id_eq].to_i
        params[:q][:entity_eq] = 'Supplier'
        @ref = params[:q][:entity_ref_eq]
      end
      if params[:vat_only]
        params[:q][:tax_home_cents_gt] = 0
      end
      # remove hack params for search
      params[:q].delete :summary_eq
      params[:q].delete :mandate_eq
    end

    @q = Financial.search(params[:q])

    limit = params[:limit].present? ? (params[:limit] || 500) : 25
    list_order = (params[:ascending].present? && params[:ascending]) == 'true' ? 'ASC' : 'DESC'

    @financials = @q.result(distinct: true).limit(limit)

    if params[:exceptions].present?
      has_posts = @financials.joins(:posts)
      @financials = @financials.where(processed: true) - has_posts
    elsif params[:processed].present?
      @q.processed_eq = processed = (params[:processed] == 'true' ? true : false)
      @financials = @financials.where(processed: processed)
    end
    if params[:event_date_gteq].present?
      @financials = @financials.where('event_date >= ?', params[:event_date_gteq] )
      @q.event_date_gteq = params[:event_date_gteq]
    end
    if params[:event_date_lteq].present?
      @financials = @financials.where('event_date <= ?', params[:event_date_lteq] )
      @q.event_date_lteq = params[:event_date_lteq]
    end
    if params[:processed].present?
      @financials = @financials.where(processed: params[:processed] )
      @q.processed_eq = params[:processed]
    end
    if params[:classification].present?
      @financials = @financials.where(classification: params[:classification] )
      @q.classification_eq = params[:classification]
    end

    if params[:credit].present?
      @financials = @financials.where('credit_amount_cents > 0')
    elsif params[:debit].present?
      @financials = @financials.where('debit_amount_cents > 0')
    end


    @debits = @financials.sum('debit_amount_cents').to_d / 100
    @credits = @financials.sum('credit_amount_cents').to_d / 100

    @financials = @financials.order("event_date #{list_order}, created_at #{list_order}")

    if params[:financial].present?
      @posts = Financial.find(params[:financial]).posts
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @financials }
    end
  end

  def entity
    entity_suppliers = get_entity_refs
    references = Supplier.where("reference <> '{}'").select(:reference).map(&:reference).flatten(1).uniq.sort { |w1, w2| w1.casecmp(w2) }
    @missing = entity_suppliers - references
    @supplier = Supplier.new
  end

  def batch

    ref_bank = params[:bank].present? ? params[:bank] : CONFIG[:default_bank]

    require "csv"
    data_file = "~john/Dropbox/commerce/#{current_tenant.domain}_#{ref_bank.downcase}.csv"
    input_file = File.expand_path(data_file)

    unless File.exist?(input_file)
      data_file = "~john/commerce/#{current_tenant.domain}_#{ref_bank.downcase}.csv"
      input_file = File.expand_path(data_file)
    end

    if File.exist?(input_file)

      @financials = []
      CSV.foreach(input_file) do |tx|
        @financials << tx
      end


      eval("batch_#{current_tenant.domain}(ref_bank)")

      end_date = @financials.first[0]

      # time = Time.now.strftime("%Y%m%d")
      label = end_date.split('/').reverse.join('')
      done = "~john/commerce/#{current_tenant.domain}_#{ref_bank.downcase}.#{label}"
      system("mv #{data_file} #{done}")
    else
      done = "Batch not found: #{input_file}"
    end

    redirect_to financials_url(result: done)

  end

  def batch_shack(ref_bank)
    counter = 0

    invoices = Financial.where(invoice: true, entity: 'Supplier')

    @financials.each do |tx|
      account = nil
      type = 'unresolved'
      summary = nil
      employee = nil
      entity_id = nil
      mandate = nil
      entity_id = nil
      entity_ref = nil
      event_date = tx[0]
      reference = tx[1].upcase.gsub(/[^0-9a-z &,]/i, '').sub('WWW', '').sub(' & ', 'AND')
      if tx[2].blank?
        credit = true
        amount = tx[3].sub(',', '').to_d
        mandate = "999"
        #mandate = reference.scan(/^*MANDATE NO [\d]+/)[0]
        #unless mandate.blank?
        #  mandate = mandate.sub('MANDATE NO ', '').to_i
        #end
        entity = 'Supplier'
        if (emp = reference.scan(/SHACKPAY \S+\s/)[0])
          type = 'payroll'
          entity = 'Employee'
          entity_ref = emp.sub('SHACKPAY ', '').sub(',', '').sub(' ', '').downcase.capitalize
          # p 'SHACKPAY'
          # p entity_ref
          entity_id = Employee.find_by_first_name(entity_ref).id
          summary = "PAYROLL #{entity_id}: #{entity_ref}"
        elsif (payee = reference.scan(/^*DIRECT DEBIT PAYMENT TO .+ REF/)[0])
          payee = payee.sub('DIRECT DEBIT PAYMENT TO ', '').sub(' REF', '')
          type = 'direct'
        elsif (payee = reference.scan(/^*CARD PAYMENT TO [^,]+/)[0])
          payee = payee.sub('CARD PAYMENT TO ', '').sub(',', '')
          type = 'card'
        elsif (payee = reference.scan(/^*CARD PAYMENT TO [a-zA-Z\s]+/)[0])
          payee = payee.sub('CARD PAYMENT TO ', '')
          type = 'card'
        elsif (payee = reference.scan(/^*BILL PAYMENT VIA FASTER PAYMENT TO [a-zA-Z\s]+ REFERENCE/)[0])
          payee = payee.sub('BILL PAYMENT VIA FASTER PAYMENT TO ', '').sub(' REFERENCE', '')
          type = 'BACS'
        elsif (payee = reference.scan(/^*BILL PAYMENT TO [a-zA-Z\s]+ REFERENCE/)[0])
          payee = payee.sub('BILL PAYMENT TO ', '').sub(' REFERENCE', '')
          type = 'BACS'
        elsif (payee = reference.scan(/^*BILL PAYMENT TO [a-zA-Z\s]+,/)[0])
          payee = payee.sub('BILL PAYMENT TO ', '').sub(',', '')
          type = 'BACS'
        elsif (payee = reference.scan(/^*BILL PAYMENT TO [a-zA-Z0-9\s]+/)[0])
          payee = payee.sub('BILL PAYMENT TO ', '')
          type = 'BACS'
        elsif (payee = reference.scan(/^*TRANSFER [a-zA-Z\s]+/)[0])
          payee = payee.sub(' TO', '')
          payee = payee.sub('TRANSFER ', '')
          type = 'transfer'
          entity = 'Bank'
          if (bank = Bank.find_by_reference(payee))
            entity_id = bank.id
          end
          entity_ref = payee
          summary = "Transfer to #{payee}"
        elsif (reference.scan(/^*CHARGES FROM/)[0] || reference.scan(/ANNUAL FEE/)[0])
          payee = 'BANK'
          type = 'charges'
          summary = 'Bank Charges'
          entity_ref = ref_bank
          supplier = Supplier.where("'#{entity_ref}' = ANY (reference)")
          supplier = Supplier.where("'SUNDRY' = ANY (reference)") unless supplier.first
          entity_id = supplier.first.id if supplier.first
          if (bank = Bank.find_by_reference(entity_ref))
            entity_id = bank.id
          end
          # summary = 'Bank Interest'
        end
        # if (emp = reference.scan(/SHACKPAY +\S[\s,]/)[0])
        #   type = 'payroll'
        #   entity = 'Employee'
        #   entity_ref = emp.sub('SHACKPAY ', '').downcase.capitalize
        #   p entity_ref
        #   entity_id = Employee.find_by_first_name(entity_ref).id
        #   summary = "PAYROLL #{entity_id}: #{entity_ref}"
        # else
        #   staff =[['JUANITA ARMITAGE', 'Juanita'], ['TYLER HOWELL', 'Tyler'], ['PAISLEY JARRA', 'Paisley'], ['VERNA ARMITAGE', 'Verna'], ['LEAH CAMPBELL', 'Leah'], ['TOM AKERY', 'Tom'], ['VICTORIA CAMPBEL', 'Victoria'], ['SOPHIE BENJAFIELD', 'Sophie'], ['MOLLY DRISCOLL', 'Molly'], ['HARRY WELCH', 'Harry'], ['JJ ARMITAGE', 'Joel'], ['DEMI HELYER', 'Demi'], ['DANIELLE PARSONS', 'Danielle'], ['YAWEN LAI', 'Emmy'], ['ABBIE MONTGOMERY', 'Abigail'], ['MELIA CAMPBELL', 'Melia'], ['ROB STOREY', 'Rob'], ['HOLLY ELLARD', 'Holly'], ['TIFFANY RICHARDS', 'Tiffany'], ['TYLER HOWELL', 'Tyler']]
        #   staff.each do |s|
        #     if reference[s[0]]
        #       type = 'payroll'
        #       entity_ref = s[1]
        #       emp = Employee.find_by_first_name(entity_ref)
        #       entity_id = !emp.blank? ? emp.id : nil
        #       entity = 'Employee'
        #     end
        #   end
        #   unless emp.blank?
        #     summary = "PAYROLL #{entity_id}: #{entity_ref}"
        #   end
        # end
        if ['direct', 'card', 'BACS'].include?(type)
          entity_ref = payee.gsub(/0-9/, '').sub(' &', '').sub(' ', '').split(' ')[0].upcase
          supplier = Supplier.where("'#{entity_ref}' = ANY (reference)")
          supplier = Supplier.where("'SUNDRY' = ANY (reference)") unless supplier.first
          entity_id = supplier.first.id if supplier.first
          summary = "#{type.capitalize} to #{payee}"
        else
          supplier = false
        end
      else
        credit = false
        amount = tx[2].sub(',', '').to_d
        entity = nil
        if (payer = reference.match(/ELAVON/))
          payer = 'EMS'
        elsif (payer = reference.scan(/^*BANK GIRO CREDIT REF [a-zA-Z0-9\s]+,/)[0])
            payer = payer.sub('BANK GIRO CREDIT REF ', '').sub(',', '').gsub(/[0-9]A/, '')
        elsif (location = reference.scan(/^*CASH DEPOSIT AT [a-zA-Z\s]+/)[0])
          location = location.sub('CASH DEPOSIT AT ', '')
          type = 'cash'
        elsif (location = reference.scan(/^*CASH PAID IN AT [a-zA-Z\s]+/)[0])
          location = location.sub('CASH PAID IN AT ', '')
          type = 'cash'
        elsif reference.scan(/^*FASTER PAYMENTS RECEIPT/)[0]
          payer = reference.scan(/^*FROM [a-zA-Z\s]+/)[0].sub('FROM ', '')
          type = 'BACS'
          entity = 'Debtor'
        elsif (location = reference.scan(/^*CHEQUE PAID IN AT [a-zA-Z\s]+/)[0])
          location = location.sub('CHEQUE PAID IN AT ', '')
          type = 'cheque'
          entity = 'Bank'
          entity_ref = 'RECEIVABLE'
          entity_id = Bank.find_by_reference(entity_ref).id
          summary = 'Cheque received'
        elsif reference.scan(/POST OFFICE CASH DEPOSIT/)[0]
          location = 'post office'
          type = 'cash'
        elsif (payer = reference.scan(/^*CREDIT FROM .+ ON/)[0])
          payer = payer.sub('CREDIT FROM ', '').sub(' ON', '')
          type = 'refund'
          entity = 'Debtor'
          entity_ref = payer.gsub(/0-9/, '').sub(' &', '').sub(' ', '').split(' ')[0]
          supplier = Supplier.where("'#{entity_ref}' = ANY (reference)")
          supplier = Supplier.where("'SUNDRY' = ANY (reference)") if supplier.empty?
          # supplier = Supplier.find_by_reference(payer.split(' ')[0]) || Supplier.find_by_reference('SUNDRY')
          entity_id = supplier.first.id unless supplier.empty?
          summary = "Refund from #{payer.split(' ')[0]}"
        elsif (payer = reference.scan(/^REJECTED .+ TO [a-zA-Z\s]+/)[0])
          payer = payer.gsub(/REJECTED .+ TO /, '')
          type = 'reverse'
          entity = 'Supplier'
          entity_ref = payer.gsub(/0-9/, '').sub(' &', '').sub(' ', '').split(' ')[0]
          supplier = Supplier.where("'#{entity_ref}' = ANY (reference)")
          supplier = Supplier.where("'SUNDRY' = ANY (reference)") if supplier.empty?
          entity_id = supplier.first.id unless supplier.empty?
          summary = "Rejected Payment to #{payer.split(' ')[0]}"
        elsif (payer = reference.scan(/^*TRANSFER FROM [a-zA-Z\s]+/)[0])
          payer = payer.sub('TRANSFER FROM ', '')
          type = 'transfer'
          entity = 'Bank'
          if (bank = Bank.find_by_reference(payer))
            entity_id = bank.id
          end
          summary = "Transfer from #{payer}"
        elsif reference.scan(/INTEREST /)[0]
          payer = 'bank'
          type = 'interest'
          entity = 'Bank'
          entity_ref = ref_bank
          if (bank = Bank.find_by_reference(entity_ref))
            entity_id = bank.id
          end
          summary = 'Bank Interest'
        end
      end
      if (type == 'cash')
        entity = 'Bank'
        entity_ref = 'CASH'
        summary = "Cash deposit"
        summary += " #{location.upcase}" unless location.blank?
      end
      if payer
        pr = payer.split(' ')[0]
        supplier = Supplier.where("'#{pr}' = ANY (reference)")
        supplier = Supplier.where("'SUNDRY' = ANY (reference)") if supplier.empty?
        entity_id = supplier.first.id unless supplier.empty?
        summary = "Receipt from #{pr}"
      end
      if entity_ref && entity_ref.scan(/PAYPAL[[a-zA-Z0-9]]*/)[0]
        entity_ref = 'PAYPAL'
      end
      if entity_ref && entity_ref.scan(/AMAZON[[a-zA-Z0-9]]*/)[0]
        entity_ref = 'AMAZON'
      end
      if reference.scan(/DIRECTORS AC/)[0] || reference.scan(/JM_VM_ARMITAGE/)[0]
        entity = 'Bank'
        entity_ref = 'DIRECTORS'
        summary = 'DIRECTORS ACCOUNT'
        type = 'transfer'
      end
      if reference.scan(/HMRC PAYE/)[0]
        entity = 'Bank'
        entity_ref = 'PAYE'
        type = 'transfer'
      end
      if reference.scan(/HMRC CUSTOMS/)[0]
        entity = 'Bank'
        entity_ref = 'VAT'
        type = 'transfer'
      end
      if payer && ['EMS', 'AX', 'ELAVON'].include?(payer)
        entity = 'Bank'
        entity_ref = payer
        type = 'merchant'
      end
      if entity == 'Bank'
        if (bank = Bank.find_by_reference(entity_ref))
          entity_id = bank.id
        end
      end
      amount = amount.to_d
      if credit
        credit_amount = amount
        debit_amount = 0
      else
        debit_amount = amount
        credit_amount = 0
      end
      entity_id = entity_id.to_i
      mandate = mandate.to_i

      summary = "Unrecognised type" if summary.blank?
      # tax?
      tax = tx.size > 5 ? tx[5] : ''
      matches = invoices.where(entity_id: entity_id, credit_amount_cents: (credit_amount * 100))
      # p event_date
      # p tx[1]
      if !matches.empty?
        invoice = matches.first
        invoice.update(invoice: false, effective_date: invoice.event_date, event_date: event_date, bank: ref_bank, classification: type, desc: tx[1], processed: false)
      else
        Financial.create!(event_date: event_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, mandate: mandate, summary: summary, desc: tx[1], debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank, account: account, tax_home: tax)
      end
    end

  end

  def show
    @posts = @financial.posts
    render 'show.js.erb'
  end

  def new
    @financial = Financial.new
    @financial.credit = true
    if params[:petty].present?
      @financial.event_date = Date.today
      @financial.bank = 'PETTY'
      @financial.classification = 'petty'
      @financial.entity = 'Supplier'
      @financial.entity_ref = 'SUNDRY'
      @financial.entity_id = Supplier.find_by_name('Sundry GBP Suppliers').id
      @financial.account_id = Account.find_by_name('Victual Costs').id
      @financial.summary = @financial.desc = 'Petty Cash Purchase'
    else
      @financial.entity = params[:entity] if params[:entity].present?
      @financial.event_date = cookies[:last_fx_date] || Date.today
      @financial.classification = @financial.entity == 'Bank' ? 'transfer' : 'BACS'
      if params[:invoice].present?
        @financial.bank = 'PAYABLE'
        @financial.invoice = true
        @financial.summary = @financial.desc = 'Invoice Received '
      else
        @financial.bank = cookies[:last_fx_bank]
      end
    end
  end

  def edit
  end

  def create

    params[:financial][:entity_ref] = get_entity_reference

    @financial = Financial.new(params[:financial])
    cookies[:last_fx_date] = @financial.event_date
    cookies[:last_fx_bank] = @financial.bank
    # transfer_account if params[:financial][:account_id].blank?

    respond_to do |format|
      if @financial.save
        format.html { redirect_to financials_url }
        format.json { render json: @financial, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @financial.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # transfer_account if params[:financial][:account_id].blank?
    # if @financial.entity_ref.blank? && params[:financial][:entity_ref].blank?
    #   params[:financial][:entity_ref] = get_entity_ref
    # end

    params[:financial][:entity_ref] = get_entity_reference if params[:financial][:entity_id].present?

    respond_to do |format|
      if @financial.update(params[:financial])
        remove_posts
        create_posts
        fixed_assets = ['Goodwill','Fixtures & Fittings','System Hardware','Furniture','Kitchen Equipment','Other Equipment']
        @account_name = @financial.account ? @financial.account.name : 'no_account'
        remove_depreciations
        if fixed_assets.include? @account_name
          create_depreciations
        end
        # if params[:editor].present?
        #   redirect_to financials_url(no_process: true), notice: 'Financial was successfully updated.'
        # else
        processed = params[:processed].present?  && params[:processed] == 'true'
        start = params[:event_date_gteq].present? ? params[:event_date_gteq] : ''
        stop = params[:event_date_lteq].present? ? params[:event_date_lteq] : ''
        hidden = params[:hidden].present? ? params[:hidden] : ''
        classification = params[:classification].present? ? params[:classification] : ''
        format.html { redirect_to financials_url(event_date_gteq: start, event_date_lteq: stop, hidden: hidden, processed: processed, classification: classification, financial: @financial.id )}
        format.json { head :no_content }
        # end
      else
        format.html { render action: 'edit' }
        format.json { render json: financial.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    remove_posts
    remove_depreciations
    @financial.destroy
    respond_to do |format|
      format.html { redirect_to financials_url }
      format.json { head :no_content }
    end
  end

  private

  def remove_depreciations
    @financial.depreciations.destroy_all
  end

  def create_depreciations
    case @account_name
      when 'Goodwill'
        months = CONFIG[:amortisation_period]
      when 'Fixtures & Fittings'
        months = CONFIG[:depreciation_period_fnf]
      when 'System Hardware','Furniture','Kitchen Equipment','Other Equipment'
        months = CONFIG[:depreciation_period_standard]
    end
    cost = @financial.credit_amount - @financial.tax_home
    allocation = (cost / months).round(2)
    allocated = 0
    service_date = @account_date + 1.month
    2.upto(months) do
      @financial.depreciations.create(service_date: service_date, allowable_cost: allocation, life_years: months)
      allocated += allocation
      service_date += 1.month
    end
    allocated = allocated.round(2)
    allocation = (cost - allocated).round(2)
    @financial.depreciations.create(service_date:service_date, allowable_cost: allocation, life_years: months)
  end

  def remove_posts
    @financial.posts.destroy_all
  end

  def create_posts
    @account_date = @financial.effective_date.blank? ? @financial.event_date : @financial.effective_date
    case @financial.classification
      when 'BACS', 'card', 'direct','petty'
        # all purchases, must be allocated to an account
        if @financial.account_id.blank?
          financial_unprocessed
        else
          payment_posts
        end
      when 'charges'
        # reference bank charges
        charges_posts
      when 'interest'
        # reference bank interest
        interest_posts
      when 'transfer'
        # between banks
        transfer_posts
      when 'reverse'
        # between banks
        reverse_posts
      when 'refund'
        # between banks
        refund_posts
      when 'merchant', 'cash'
        # incoming funds
        receipt_posts
      when 'cheque'
        # incoming cheque
        cheque_posts
      when 'payroll'
        # wage payment
        wages_posts
    end
  end

  def payment_posts
    account = @financial.account
    if @financial.entity == 'Supplier'
      entity = Supplier.find(@financial.entity_id)
    else
      entity = Employee.find(@financial.entity_id)
    end
    desc = "#{account.name} debit: #{entity.name}"
    net = @financial.credit_amount
    if @financial.entity == 'Supplier' && @financial.tax_home && @financial.tax_home > 0
      net -= @financial.tax_home
      vat_post(entity)
    end
    bank_credit_post(entity)
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: net, credit_amount: 0, account_id: account.id,
                                     accountable_type:@financial.entity, accountable_id: @financial.entity_id, grouping_id: account.grouping_id)
    financial_processed
  end

  def cheque_posts
    bank_ref = @financial.bank
    bank = Bank.find_by_reference( bank_ref )
    bank_account = Account.find_by_name(bank.name)
    entity = Bank.find(@financial.entity_id)
    entity_ref = entity.reference
    entity_account = Account.find_by_name(entity.name)
    desc = "#{bank_account.name} cheque: #{entity.name}"
    # Received by
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                              debit_amount: @financial.debit_amount, credit_amount: 0, account_id: bank_account.id,
                              accountable_type:'Bank', accountable_id: bank.id, grouping_id: bank_account.grouping_id)
    # Received from
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                              debit_amount: 0, credit_amount: @financial.debit_amount, account_id: entity_account.id,
                              accountable_type: 'Bank', accountable_id: entity.id, grouping_id: entity_account.grouping_id)
    if bank_account.name = 'RECEIVABLE'
      net = @financial.debit_amount / (1 + CONFIG[:vat_rate_standard])
      tax = @financial.debit_amount - net
      # Sales
      account = Account.find_by_name('Sales')
      @financial.posts.create( account_date:  @account_date, desc: desc,
                               debit_amount: 0, credit_amount: net, account_id:account.id,
                               accountable_type:'Account', accountable_id:account.id, grouping_id: account.grouping_id)
      # VAT
      account = Account.find_by_name('VAT Control')
      @financial.posts.create!( account_date:  @account_date, desc: desc,
                                debit_amount: 0, credit_amount: tax, account_id: account.id,
                                accountable_type: 'Account', accountable_id: account.id, grouping_id: account.grouping_id)
      account = Account.find_by_name('Sales Pending')
      @financial.posts.create( account_date:  @account_date, desc: desc,
                               debit_amount: net, credit_amount: 0, account_id: account.id,
                               accountable_type:'Account', accountable_id: account.id, grouping_id: account.grouping_id)
      account = Account.find_by_name('VAT Pending')
      @financial.posts.create( account_date:  @account_date, desc: desc,
                               debit_amount: tax, credit_amount: 0, account_id:account.id,
                               accountable_type:'Account', accountable_id: account.id, grouping_id: account.grouping_id)
    end
    financial_processed
  end

  def charges_posts
    account = Account.find_by_name('Bank Charges')
    supplier = Supplier.where("'#{@financial.entity_ref}' = ANY (reference)").first
    desc = "#{account.name} debit: #{supplier.name}"
    net = @financial.credit_amount
    # bank_credit_post(supplier)
    post = @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: net, credit_amount: 0, account_id: account.id,
                                     accountable_type:'Supplier', accountable_id:  supplier.id, grouping_id: account.grouping_id)
    bank_ref = @financial.bank
    bank = Bank.find_by_reference( bank_ref )
    account = Account.find_by_name(bank.name)
    desc = "#{account.name} credit: #{supplier.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: 0, credit_amount: net, account_id: account.id,
                                     accountable_type:'Supplier', accountable_id: supplier.id, grouping_id: account.grouping_id)
    financial_processed
  end

  def interest_posts
    account = Account.find_by_name('Bank Interest')
    supplier = Supplier.where("'#{@financial.entity_ref}' = ANY (reference)").first
    desc = "#{account.name} credit: #{supplier.name}"
    net = @financial.debit_amount
    # bank_credit_post(supplier)
    post = @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: 0, credit_amount: net, account_id: account.id,
                                     accountable_type:'Supplier', accountable_id: supplier.id, grouping_id: account.grouping_id)
    bank_ref = @financial.bank
    bank = Bank.find_by_reference( bank_ref )
    account = Account.find_by_name(bank.name)
    desc = "#{account.name} debit: #{supplier.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: net, credit_amount: 0, account_id: account.id,
                                     accountable_type:'Supplier', accountable_id: supplier.id, grouping_id: account.grouping_id)
    financial_processed
  end

  def transfer_posts
    bank_ref = @financial.bank
    ref_bank = Bank.find_by_reference( bank_ref )
    ref_account = Account.find_by_name(ref_bank.name)
    tx_bank = Bank.find( @financial.entity_id )
    tx_account = Account.find_by_name(tx_bank.name)
    if @financial.credit_amount > 0
      to_bank = tx_bank
      to_account = tx_account
      from_bank = ref_bank
      from_account = ref_account
      amount = @financial.credit_amount
    else
      to_bank = ref_bank
      to_account = ref_account
      from_bank = tx_bank
      from_account = tx_account
      amount = @financial.debit_amount
    end
    desc = "#{from_bank.name} to: #{to_bank.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: 0, credit_amount: amount, account_id: from_account.id,
                                     accountable_type:'Bank', accountable_id: to_bank.id, grouping_id: from_account.grouping_id)
    desc = "#{to_bank.name} from: #{from_bank.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: amount, credit_amount: 0, account_id: to_account.id,
                                     accountable_type:'Bank', accountable_id: from_bank.id, grouping_id: to_account.grouping_id)
    financial_processed
  end

  def receipt_posts
    bank_ref = @financial.bank
    to_bank = Bank.find_by_reference( bank_ref )
    to_account = Account.find_by_name(to_bank.name)
    @financial.entity_ref = 'EMS' if @financial.entity_ref == 'ELAVON' #TEMP FIX
    from_bank = Bank.find_by_reference( @financial.entity_ref)
    from_account = Account.find_by_name(from_bank.name)
    desc = "#{from_bank.name} to: #{to_bank.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: 0, credit_amount: @financial.debit_amount, account_id: from_account.id,
                                     accountable_type:'Bank', accountable_id: to_bank.id, grouping_id: from_account.grouping_id)
    desc = "#{to_bank.name} from: #{from_bank.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: @financial.debit_amount, credit_amount: 0, account_id: to_account.id,
                                     accountable_type:'Bank', accountable_id: from_bank.id, grouping_id: to_account.grouping_id)
    financial_processed
  end

  def reverse_posts
    bank_ref = @financial.bank
    bank = Bank.find_by_reference( bank_ref )
    account = Account.find_by_name(bank.name)
    case @financial.entity
      when 'Employee'
        ref_account = Account.find_by_name('Wages Payable')
        entity = Employee.find(@financial.entity_id)
      when 'Supplier'
        ref_account = Account.find_by_name('Accounts Payable')
        entity = Supplier.find(@financial.entity_id)
    end
    net = @financial.debit_amount

    desc = "#{account.name} reverse: #{entity.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: net, credit_amount: 0, account_id: account.id,
                                     accountable_type:@financial.entity, accountable_id: @financial.entity_id, grouping_id: account.grouping_id)
    desc = "#{ref_account.name} reverse: #{entity.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: 0, credit_amount: net, account_id: ref_account.id,
                                     accountable_type: @financial.entity, accountable_id:@financial.entity_id, grouping_id: ref_account.grouping_id)

    financial_processed

  end

  def refund_posts
    account = Account.find(@financial.account_id)
    supplier = Supplier.where("'#{@financial.entity_ref}' = ANY (reference)").first
    desc = "#{account.name} refund: #{supplier.name}"
    net = @financial.debit_amount
    net -= @financial.tax_home if @financial.tax_home
    # bank_credit_post(supplier)
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: 0, credit_amount: net, account_id: account.id,
                                     accountable_type: 'Supplier', accountable_id: supplier.id, grouping_id: account.grouping_id)
    bank_ref = @financial.bank
    bank = Bank.find_by_reference( bank_ref )
    account = Account.find_by_name(bank.name)
    desc = "#{account.name} refund: #{supplier.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: @financial.debit_amount, credit_amount: 0, account_id: account.id,
                                     accountable_type:'Supplier', accountable_id: supplier.id, grouping_id: account.grouping_id)

    if @financial.tax_home && @financial.tax_home > 0.00
      bank_name = 'VAT Control'
      bank = Bank.find_by_name( bank_name )
      account = Account.find_by_name(bank_name)
      desc = "#{account.name} refund: #{supplier.name}"
      @financial.posts.create!( account_date:  @account_date, desc: desc,
                                       debit_amount: 0, credit_amount: @financial.tax_home, account_id: account.id,
                                       accountable_type:'Supplier', accountable_id: supplier.id, grouping_id: account.grouping_id)
    end

    financial_processed
  end

  def wages_posts
    account = Account.find_by_name('Wages Payable')
    employee = Employee.find(@financial.entity_id)
    desc = "#{account.name} debit: #{employee.name}"
    net = @financial.credit_amount
    bank_credit_post(employee)
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: net, credit_amount: 0, account_id: account.id,
                                     accountable_type:'Employee', accountable_id: @financial.entity_id, grouping_id: account.grouping_id)
    financial_processed
  end

  def vat_post(supplier)
    bank_name = 'VAT Control'
    bank = Bank.find_by_name( bank_name )
    account = Account.find_by_name(bank_name)
    desc = "#{account.name} debit: #{supplier.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: @financial.tax_home, credit_amount: 0, account_id: account.id,
                                     accountable_type:'Supplier', accountable_id: supplier.id, grouping_id: account.grouping_id)
  end

  def bank_credit_post(entity)
    bank_ref = @financial.bank
    bank = Bank.find_by_reference( bank_ref )
    account = Account.find_by_name(bank.name)
    desc = "#{account.name} credit: #{entity.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: 0, credit_amount: @financial.credit_amount, account_id: account.id,
                                     accountable_type: @financial.entity, accountable_id: entity.id, grouping_id: account.grouping_id)
  end

  def bank_debit_post
    bank_ref = @financial.bank
    bank = Bank.find_by_reference( bank_ref )
    account = Account.find_by_name(bank.name)
    desc = "#{account.name} debit: #{entity.name}"
    @financial.posts.create!( account_date:  @account_date, desc: desc,
                                     debit_amount: @financial.debit_amount, credit_amount: 0, account_id: account.id,
                                     accountable_type: @financial.entity, accountable_id: entity.id, grouping_id: account.grouping_id)
  end

  def financial_processed
    @financial.update!(processed: true)
  end

  def financial_unprocessed
    @financial.update!(processed: false)
  end

  # def get_entity_ref
  #   ref = ''
  #   case @financial.entity
  #     when 'Supplier'
  #       supplier_ref = Supplier.find(@financial.entity_id).reference
  #       ref = supplier_ref.first if supplier_ref
  #     when 'Bank'
  #       ref = Bank.find(@financial.entity_id).reference
  #     when 'Employee'
  #       ref = Employee.find(@financial.entity_id).reference
  #   end
  #   ref
  # end
  #
  def get_banks
    Bank.where( 'reference IS NOT NULL' ).order(:rank)
  end
  def get_target_banks
    target_bank_ids = Financial.where(entity: 'Bank').select(:entity_id).map(&:entity_id).uniq.sort_by(&:to_i)
    @banks.where( id: target_bank_ids )
  end
  def get_classes
    Financial.where('classification IS NOT NULL').select(:classification).map(&:classification).uniq.sort { |w1, w2| w1.casecmp(w2) }
  end
  def get_entity_suppliers
    supplier_ids = Financial.where('entity_id IS NOT NULL').where(entity: 'Supplier').select(:entity_id).map(&:entity_id).uniq.sort_by(&:to_i)
    Supplier.where( id: supplier_ids ) #.order(:id)
  end

  def get_entity_reference
    case params[:financial][:entity]
      when 'Supplier'
        Supplier.find(params[:financial][:entity_id]).reference.first
      when 'Employee'
        e = Employee.find(params[:financial][:entity_id])
        e.reference.blank? ? e.first_name.upcase : e.reference.upcase
      when 'Bank'
        Bank.find(params[:financial][:entity_id]).reference
    end
  end


  def get_entity_refs
    Financial.where('entity_ref IS NOT NULL').where(entity: 'Supplier').select(:entity_ref).map(&:entity_ref).uniq.sort { |w1, w2| w1.casecmp(w2) }
  end

  def get_entity_employees
      Financial.where('entity_ref IS NOT NULL').where(entity: 'Employee').select(:entity_ref).map(&:entity_ref).uniq.sort { |w1, w2| w1.casecmp(w2) }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_financial
      @financial = Financial.find(params[:id])
    end

  def current_resource
    @current_resource ||= @financial
  end
end
