class ValidatesController < ApplicationController
 
  def index
    url = params[:url]

    file_v4 = "#{Rails.root}/app/assets/images/ipv4.png"
    file_v6 = "#{Rails.root}/app/assets/images/ipv6.png"

    if url.blank?
      send_file file_v4, :type => 'image/png', :disposition => 'inline'
    else
      begin

        c = Utils.check_www url
        
        logger.debug(c)
        unless c.kind_of?(Array)
          send_file file_v4, :type => 'image/png', :disposition => 'inline'
        else
          if c.last > 0
            send_file file_v6, :type => 'image/png', :disposition => 'inline'
          else
            send_file file_v4, :type => 'image/png', :disposition => 'inline'
          end
        end
      rescue 
        send_file file_v4, :type => 'image/png', :disposition => 'inline'
      end
    end
  end

  def html

    @domain = params[:domain]
    render :layout => nil 
  end
end