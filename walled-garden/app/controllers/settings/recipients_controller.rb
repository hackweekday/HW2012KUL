class Settings::RecipientsController < ApplicationController
  set_tab :recipient, :first_level
  # GET /recipients
  # GET /recipients.json
  def manual_mail_report
    file_name = []
    if params[:search_option] == "day"
      date_a = params[:date]
      date_b = date_a
      showdate = date_a
    elsif params[:search_option] == "range"
      d = params[:start_date].split(" ")
      date_a = d[2]
      date_b = d[0]
      showdate = "#{date_b} to #{date_a}"
    end
    file_name.push (Dnscell::Graph.generate_global_report date_a, date_b, "global", "all") if (o "global_enable") == "true"
    Option.find_by_statement("zone_for_report").statement_value.split(" ").each do |z|
      file_name.push Dnscell::Graph.generate_zone_report z, date_a, date_b
    end

    if (o "global_report_available") == "true" && (Dnscell::Email.mail_report file_name, "Manual #{showdate}").deliver
      render :js => "show_flash('Report has been sent.')"
    else
      render :js => "show_flash('Error while sending report. #{'No record for this date' if (o "global_report_available") == 'false'}')"
    end
  end

  def save_report
    if check_report_mailer == true
      case params[:statement]
      when "report_mailer_enable"
        save_to_option
        if params[:statement_value] == "false"
          Option.find_or_initialize_by_statement("last_report_sent").update_attributes(:statement_value => "")
          render :js => "
          window.location = '#{settings_recipients_path}'
          "
        else
          if EmailGroupName.find((o "report_mailer_to_group_id")).emails.length.zero?
            Option.find_by_statement("report_mailer_to_group_id").update_attributes(:statement_value => EmailGroup.first.email_group_name_id)
            flash[:notice] = "Automatically selecting group with an email."
          end
          render :js => "
          window.location = '#{settings_recipients_path}'
          "
        end
      when "report_mailer_to_group_id"
        if EmailGroupName.find(params[:statement_value]).emails.length.zero?
          render :js => "
          show_error([\"Unable to use this group. No email in this group. Process Reverted.\"])
          $('#report_mailer_to_group_id').val('#{(o "report_mailer_to_group_id")}')
          setTimeout(\"$('.my_error_msg').slideUp()\", 7000)
          "
        else
          save_to_option
          emails = EmailGroupName.find(params[:statement_value]).emails.map{|x| x.address }.join(", ")
          render :js => "hide_errors(); $('.email_list').html('<h4>Email List</h4>#{emails}')"
        end
      else
        save_to_option
        render :nothing => true
      end
      # Option.find_or_initialize_by_statement(params[:statement]).update_attributes(:statement_value => params[:statement_value])
      # if params[:statement] == "report_mailer_enable"
      #   if params[:statement_value] == "false"
      #     Option.find_or_initialize_by_statement("last_report_sent").update_attributes(:statement_value => "")
      #     render :js => "
      #     window.location = '#{settings_recipients_path}'
      #     "
      #   else
      #     if EmailGroupName.find((o "report_mailer_to_group_id")).emails.length.zero?
      #       Option.find_by_statement("report_mailer_to_group_id").update_attributes(:statement_value => EmailGroup.first.email_group_name_id)
      #     end
      #     render :js => "
      #     //hide_errors()
      #     //display_setting_state()
      #     window.location = '#{settings_recipients_path}'
      #     "
      #   end
      # elsif params[:statement] == "report_mailer_to_group_id"
      #   if EmailGroupName.find(params[:statement_value]).emails.length.zero?
      #     render :js => "show_error([\"Unable to use this group. No email in that group.\"])"
      #   else
      #     render :nothing => true
      #   end
      # else
      #   render :nothing => true
      # end
    else
      render :js => "
      //setTimeout('display_setting_state()', 1)
      $('.tzCheckBox').toggleClass('checked');
      $('.manual_report_wrapper').hide()
      $('.report_mailer_enable').attr('checked', false);
      display_setting_state()
      show_error([\"#{@error}\"])"
    end
  end

  def index
    if check_report_mailer
      logger.debug "xx #{check_report_mailer}"
      if SmtpSetting.first.nil?
        redirect_to smtp_settings_path
      else    
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @recipients }
        end
      end
    else
      logger.debug "xx #{check_report_mailer}"
      Option.find_by_statement("report_mailer_enable").update_attributes(:statement_value => "false")
    end
  end

  # GET /recipients/1
  # GET /recipients/1.json
  def show
    @recipient = Recipient.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recipient }
    end
  end

  # GET /recipients/new
  # GET /recipients/new.json
  def new
    @recipient = Recipient.new
  end

  # GET /recipients/1/edit
  def edit
    @recipient = Recipient.find(params[:id])
  end

  # POST /recipients
  # POST /recipients.json
  def create
    @recipient = Recipient.new(params[:recipient])
      if @recipient.save
        all_recipient
      else
        render :js => "show_error(eval(#{@recipient.errors.full_messages}))"
      end
  end

  # PUT /recipients/1
  # PUT /recipients/1.json
  def update
    @recipient = Recipient.find(params[:id])

    respond_to do |format|
      if @recipient.update_attributes(params[:recipient])
        format.html { redirect_to @recipient, notice: 'Recipient was successfully updated.' }
        format.json { render json: @recipient }
      else
        format.html { render action: "edit" }
        format.json { render json: @recipient.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipients/1
  # DELETE /recipients/1.json
  def destroy
    @recipient = Recipient.find(params[:id])
    @recipient.destroy
    all_recipient
    render 'create.js'
  end

  def all_recipient
    @recipients = Recipient.order("created_at desc")
  end

  def save_zone_for_report
    o = Option.find_by_statement("zone_for_report")
    zones = ""
    unless params[:zone].nil?
      params[:zone].each do |z|
        zones += z + " "
      end
      o.update_attributes(:statement_value => zones)
    else
      o.update_attributes(:statement_value => "")
    end
    render :nothing => true
  end

  def save_report_interval
    o = Option.find_by_statement("mail_report_interval")
    inter = ""
    params[:interval].each do |iv|
      inter += iv + " "
    end
    o.update_attributes(:statement_value => inter)
    render :nothing => true
  end

  def save_report_mailer

  end

  def save_to_option
      Option.find_or_initialize_by_statement(params[:statement]).update_attributes(:statement_value => params[:statement_value])
  end
end
