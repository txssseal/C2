module ApplicationHelper
  # Variation of https://git.io/ugBzaQ
  def humanized_options_for_select(options)
    options = options.map do |val|
      [val.humanize, val]
    end
    options_for_select(options)
  end

  def controller_name
    params[:controller].gsub(/\W/, '-')
  end

  def bootstrap_alert_class(key)
    suffix = case key.to_sym
      when :notice
        'info'
      when :error
        'danger'
      else
        key
      end

    "bg-#{suffix}"
  end

  def flash_message(val)
    if val.is_a?(Enumerable)
      val.join('. ')
    else
      val
    end
  end

  def flash_list
    flash.map do |key, val|
      [key, flash_message(val)]
    end
  end

  def excluded_portal_link
    controller_name == 'home' ||
    current_page?(proposals_path)
  end

  def auth_path
    '/auth/myusa'
  end
end
