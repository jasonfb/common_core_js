module CommonCoreJs
  module ApplicationHelper

    def datetime_field_localized(form_object, field_name, value, label, timezone = nil )
      res = form_object.label(label,
                              field_name,
                              class: 'small form-text text-muted')

      res << form_object.text_field(field_name, class: 'form-control',
                                    type: 'datetime-local',
                                    value: date_to_current_timezone(value, timezone))

      res << human_timezone(Time.now, timezone)
      res
    end


    def date_field_localized(form_object, field_name, value, label, timezone = nil )
      res = form_object.label(label,
                              field_name,
                              class: 'small form-text text-muted')

      res << form_object.text_field(field_name, class: 'form-control',
                                    type: 'date',
                                    value: value )

      res
    end

    def time_field_localized(form_object, field_name, value, label, timezone = nil )
      res = form_object.label(label,
                              field_name,
                              class: 'small form-text text-muted')

      res << form_object.text_field(field_name, class: 'form-control',
                                    type: 'time',
                                    value: date_to_current_timezone(value, timezone))

      res << human_timezone(Time.now, timezone)
      res
    end

    def current_timezone
      if method(:current_user)
        if current_user.try(:timezone)
          Time.now.in_time_zone(current_user.timezone).strftime("%z").to_i/100
        else
          Time.now.strftime("%z").to_i/100
        end
      else
        raise "no method current_user is available or it does not implement timezone; please implement/override the method current_timezone"
      end
    end

    def human_timezone(time_string, timezone)
      time = time_string.in_time_zone(timezone)

      if time.zone.match?(/^\w/)
        time.zone
      else
        time.formatted_offset
      end
    end

    def date_to_current_timezone(date, timezone = nil)
      # if the timezone is nil, use the server date'
      if timezone.nil?
        timezone = Time.now.strftime("%z").to_i/100
      end

      return nil if date.nil?

      begin
        return date.in_time_zone(timezone).strftime("%Y-%m-%dT%H:%M")
      rescue
        return nil
      end
    end
  end
end
