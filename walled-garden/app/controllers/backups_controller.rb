class BackupsController < ApplicationController
	set_tab :operation, :first_level, :only => %w(index)
	set_tab :files, :first_level, :only => %w(archive)

	def index
		# render :text => "S"
	end

	def archive
		@archives = `ls -la #{Rails.root.join("public", "backup")}`.split("\n")[3..-1]
	end

	def download
		send_file "#{BACKUP_DIR}/#{params[:file]}", :x_sendfile=>true
	end

	def backup_now
		begin
			Dnscell::Backup.do_now
			render :js => "
						show_flash('Backup successfull.')
					"
		rescue Exception => e
			logger.debug "xx error #{e.message}"
			render :nothing => true
		end
	end

	def set_interval
		opt = Option.find_by_statement("backup_interval")
		opt.update_attributes(:statement_value => params[:interval])
		render :js => "show_flash('Interval saved.')"
	end

	def keep_backup_file
		opt = Option.find_by_statement("keep_backup_file")
		opt.update_attributes(:statement_value => params[:v])
		render :js => "show_flash('Backup files duration saved.')"
	end

	def restore
		Dnscell::Backup.restore params[:filename]
		render :js => "
			show_flash('Restore successfull.')
		"
	end

	def restore_file
		# tmp = DataFile.new(params[:file])
		if DataFile.save(params[:file])
			render :js => "
				$('.upload_form').dialog('close')
				hide_errors()
				show_flash('Restoring process completed.')
				$('.backup_status').html('')
			"
		else
			render :js => "
				show_error(['Unable to backup this file.'])
				$('.backup_status').html('')
			"
		end
	end

	def file_restore_auth
		if User.find_by_username("admin").valid_password?(params[:password])
		else
			render :js => "show_error(['Invalid password.'])"
		end
	end

	def delete
		logger.debug "xx files #{params[:files]}"
		params[:files].each do |f|
			`rm -rf #{Rails.root.join("public","backup", f)}`
		end
		flash[:notice] = "File deleted."
		redirect_to archive_backups_path
	end
end