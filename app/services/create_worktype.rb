class CreateWorkType
  def self.call(work_type_params, date_entered, entries)
    begin
      work_type = work_type.new
      entries.size.times do |i|
        work_type.work_type_amount.build
      end
        
      @form = work_typeForm.new(work_type)
      work_type_params[:work_type_amount] = entries
      if !@form.validate(work_type_params)
        puts "#{@form.errors}"
        raise "Form failed to validate with errors #{@form.errors}"
      end
      @form.save

      work_type = @form.model
      work_type.update_attribute :date_entered, date_entered if date_entered.present?
      work_type.update_attribute :work_type_no, Generatework_typeNo.call(work_type.date_entered.year)

      work_type
    rescue => e
      puts "error occured creating work_type with the title #{work_type_params[:previous_work_type_no]} - #{e}"
      false
    end
  end
end
