class FinancialsController < ApplicationController
  before_action :set_financial, only: [:show, :edit, :update, :destroy]

  # GET /transactions
  # GET /transactions.json
  def index
    @financials = Financial.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @financials }
    end
  end

  def batch

    ref_bank = params[:bank].present? ? params[:bank] : CONFIG[:default_bank]

    require "csv"
    data_file = "~/commerce/#{ref_bank.downcase}.csv"
    @financials = []
    CSV.foreach(File.expand_path(data_file)) do |tx|
      @financials << tx
    end
    counter = 0
    @financials.each do |tx|
      type = 'unresolved'
      summary = nil
      employee = nil
      entity_id = nil
      mandate = nil
      entity_id = nil
      entity_ref = nil
      event_date = tx[0]
      reference = tx[1].upcase.gsub(/[^0-9a-z &,]/i, '').sub('WWW', '').sub(' & ','AND')
      if tx[2].blank?
        credit = true
        amount = tx[3].sub(',', '').to_d
        mandate = reference.scan(/^*MANDATE NO [\d]+/)[0]
        unless mandate.blank?
          mandate = mandate.sub('MANDATE NO ', '').to_i
        end
        entity = 'Supplier'
        if (payee = reference.scan(/^*DIRECT DEBIT PAYMENT TO .+ REF/)[0])
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
        elsif (payee = reference.scan(/^*TRANSFER TO [a-zA-Z\s]+/)[0])
          payee = payee.sub('TRANSFER TO ', '')
          type = 'transfer'
          entity = 'Bank'
          if ( bank = Bank.find_by_reference(payee))
            entity_id = bank.id
          end
          entity_ref = payee
          summary = "Transfer to #{payee}"
        elsif (reference.scan(/^*CHARGES FROM/)[0] || reference.scan(/ANNUAL FEE/)[0])
          payee = 'BANK'
          type = 'charges'
          summary = 'Bank Charges'
        end
        if (entity_id = reference.scan(/SHACKPAYROLL\d+/)[0])
          type = 'payroll'
          entity_id = entity_id.sub('SHACKPAYROLL','')
          entity = 'Employee'
          summary = "Payroll ID: #{entity_id}"
        else
          staff =[['SOPHIE BENJAFIELD', 'Sophie'], ['MOLLY DRISCOLL', 'Molly'], ['HARRY WELCH', 'Harry'], ['JJ ARMITAGE', 'Joel'], ['DEMI HELYER', 'Demi'], ['DANIELLE PARSONS', 'Danielle'], ['YAWEN LAI', 'Emmy'], ['ABBIE MONTGOMERY', 'Abigail'], ['MELIA CAMPBELL', 'Melia'], ['ROB STOREY', 'Rob'], ['HOLLY ELLARD', 'Holly'], ['TIFFANY RICHARDS', 'Tiffany'], ['TYLER HOWELL', 'Tyler']]
          staff.each do |s|
            if reference[s[0]]
              type = 'payroll'
              employee = s[1]
              emp = Employee.find_by_first_name(s[1])
              entity_id = !emp.blank? ? emp.id : nil
              entity = 'Employee'
            end
          end
          unless employee.blank?
            summary = "PAYROLL: #{employee}"
          end
        end
        if ['direct', 'card', 'BACS'].include?(type)
          entity_ref = payee.gsub(/0-9/,'').sub(' &','').sub(' ','').split(' ')[0]
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
        if (payer = reference.scan(/^*BANK GIRO CREDIT REF [a-zA-Z0-9\s]+,/)[0])
          payer = payer.sub('BANK GIRO CREDIT REF ', '').sub(',','').gsub(/[0-9]/,'')
          type = 'merchant'
        elsif (location = reference.scan(/^*CASH DEPOSIT AT [a-zA-Z\s]+/)[0])
          location = location.sub('CASH DEPOSIT AT ', '')
          type = 'cash'
        elsif (location = reference.scan(/^*CASH PAID IN AT [a-zA-Z\s]+/)[0])
          location = location.sub('CASH PAID IN AT ', '')
          type = 'cash'
        elsif reference.scan(/^*FASTER PAYMENTS RECEIPT/)[0]
          payer = reference.scan(/^*FROM [a-zA-Z\s]+/)[0].sub('FROM ', '')
          type = 'bacs'
          entity = 'Debtor'
        elsif (location = reference.scan(/^*CHEQUE PAID IN AT [a-zA-Z\s]+/)[0])
          location = location.sub('CHEQUE PAID IN AT ', '')
          type = 'cheque'
          entity = 'Debtor'
          summary = 'Cheque received'
        elsif reference.scan(/POST OFFICE CASH DEPOSIT/)[0]
          location = 'post office'
          type = 'cash'
        elsif (payer = reference.scan(/^*CREDIT FROM .+ ON/)[0])
          payer = payer.sub('CREDIT FROM ', '').sub(' ON', '')
          type = 'refund'
          entity = 'Debtor'
          entity_ref = payer.gsub(/0-9/,'').sub(' &','').sub(' ','').split(' ')[0]
          supplier = Supplier.where("'#{entity_ref}' = ANY (reference)")
          supplier = Supplier.where("'SUNDRY' = ANY (reference)") if supplier.empty?
          # supplier = Supplier.find_by_reference(payer.split(' ')[0]) || Supplier.find_by_reference('SUNDRY')
          entity_id = supplier.first.id unless supplier.empty?
          summary = "Refund from #{payer.split(' ')[0]}"
        elsif (payer = reference.scan(/^REJECTED .+ TO [a-zA-Z\s]+/)[0])
          payer = payer.gsub(/REJECTED .+ TO /, '')
          type = 'reverse'
          entity = 'Supplier'
          entity_ref = payer.gsub(/0-9/,'').sub(' &','').sub(' ','').split(' ')[0]
          supplier = Supplier.where("'#{entity_ref}' = ANY (reference)")
          supplier = Supplier.where("'SUNDRY' = ANY (reference)") if supplier.empty?
          entity_id = supplier.first.id unless supplier.empty?
          summary = "Rejected Payment to #{payer.split(' ')[0]}"
        elsif (payer = reference.scan(/^*TRANSFER FROM [a-zA-Z\s]+/)[0])
          payer = payer.sub('TRANSFER FROM ', '')
          type = 'transfer'
          entity = 'Bank'
          if ( bank = Bank.find_by_reference(payee))
            entity_id = bank.id
          end
          summary = "Transfer from #{payer}"
        elsif reference.scan(/INTEREST PAID/)[0]
          payer = 'bank'
          type = 'interest'
          entity = 'Debtor'
          summary = 'Bank Interest'
        end
      end
      if (type == 'cash')
        entity = 'Bank'
        entity_ref = 'CASH'
        summary = "Cash deposit"
        summary += " #{location.upcase}" unless location.blank?
      end
      # if (payee && ['HMRC', 'JMVMARMITAGE', 'JONATHANARMITAGE', 'JARMITAGE'].include?(payee.split(' ')[0])) || (payer && ['EMS', 'AX', 'JMVMARMITAGE', 'JONATHANARMITAGE', 'JARMITAGE'].include?(payer.split(' ')[0]))
      #   type = 'transfer'
      #   entity = 'Bank'
      # end
      if payer
        pr =  payer.split(' ')[0]
        supplier = Supplier.where("'#{pr}' = ANY (reference)")
        supplier = Supplier.where("'SUNDRY' = ANY (reference)") if supplier.empty?
        entity_id = supplier.first.id unless supplier.empty?
        summary = "Receipt from #{pr}"
      end


      if reference.scan(/LOAN REPAYMENT/)[0] || reference.scan(/DIRECTORS LOAN/)[0]
        entity = 'Bank'
        entity_ref = 'DIRECTORS'
        summary = 'DIRECTORS LOAN'
      end
      if reference.scan(/HMRC PAYE/)[0]
        entity = 'Bank'
        entity_ref = 'PAYE'
      end
      if reference.scan(/HMRC CUSTOMS/)[0]
        entity = 'Bank'
        entity_ref = 'VAT'
      end
      if payer && ['EMS', 'AX'].include?(payer.split(' ')[0])
        entity = 'Bank'
        entity_ref = payer.split(' ')[0]
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
      # f = Financial.create(event_date: event_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, mandate: mandate, desc: tx[1], debit_amount: debit_amount, credit_amount: credit_amount)
      # if counter < 50
      #   counter += 1
      Financial.create!(event_date: event_date, credit: credit, classification: type, entity: entity, entity_id: entity_id, entity_ref: entity_ref, mandate: mandate, summary: summary, desc: tx[1], debit_amount: debit_amount, credit_amount: credit_amount, bank: ref_bank)
      #   p f
      # end
      # p event_date
      # p "#{credit ? 'Out' : 'In'}: "
      # p type
      # p "Amount: #{amount}"
      # p "Employee: #{employee}" if type['payroll']
      # p "ID: #{employee_id}"  if type['payroll']
      # p "Supplier: #{supplier_id}" if supplier
      # p "Mandate: #{mandate}" if mandate
      # p "Payee: #{payee}" if payee
      # p "Payer: #{payer}" if payer
      # p "Location: #{location}" if location

    end

    redirect_to financials_url

  end

  def processor

  end
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: financial }
    end
  end

  def new
    @financial = Financial.new
  end

  def edit
  end

  def create
    @financial = Financial.new(params[:financial])
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
    respond_to do |format|
      if @financial.update(params[:financial])
        format.html { redirect_to financials_url }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: financial.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @financial.destroy
    respond_to do |format|
      format.html { redirect_to financials_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_financial
      @financial = Financial.find(params[:id])
    end

  def current_resource
    @current_resource ||= @financial
  end
end
