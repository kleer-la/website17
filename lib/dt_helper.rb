require 'json'
require 'i18n'

class DTHelper
  MONTHS_ES = { 'Jan' => 'Ene', 'Feb' => 'Feb', 'Mar' => 'Mar', 'Apr' => 'Abr', 'May' => 'May', 'Jun' => 'Jun',
                'Jul' => 'Jul', 'Aug' => 'Ago', 'Sep' => 'Sep', 'Oct' => 'Oct', 'Nov' => 'Nov', 'Dec' => 'Dic' }.freeze

  def self.to_dt_event_array_json(events, remote = true, event_details_path = 'cursos', i18n = I18n, locale = 'es', amount = nil, registration_btn = true)
    result = []

    printed = 0

    events.each do |event|
      result << DTHelper.event_result_json(event, remote, event_details_path, i18n, locale,
                                           registration_btn)
      printed += 1
      break if !amount.nil? && printed == amount
    end

    "{ \"data\": #{result.to_json}}"
  end

  def self.event_result_json(event, _remote = true, _event_details_path = 'cursos', i18n, locale, registration_btn)
    result = []

    date_line = '<table border="0" align="center" cellpadding="2"><tr>'
    if event.date != event.finish_date && !event.finish_date.nil?
      post_it_width = '80px;'
      date_line += "<td>#{event.date.strftime('%d')}</td>"
      date_line += '<td rowspan=2>&nbsp;-&nbsp;</td>'
      date_line += "<td>#{event.finish_date.strftime('%d')}</td>"
      date_line += '</tr><tr>'
      date_line += "<td>#{MONTHS_ES[event.date.strftime('%b')]}</td>"
      date_line += "<td>#{MONTHS_ES[event.finish_date.strftime('%b')]}</td>"
    else
      post_it_width = '40px;'
      date_line += "<td>#{event.date.strftime('%d')}</td>"
      date_line += '</tr><tr>'
      date_line += "<td>#{MONTHS_ES[event.date.strftime('%b')]}</td>"
    end
    date_line += '</tr></table>'

    result << "<div class=\"klabel-date\" style=\"width:#{post_it_width}\">#{date_line}</div>"

    # Nueva versión yendo al tipo de evento
    
    href = "href=\"/#{locale}/#{event.event_type.uri_path}\""
    href = "href=#{event.event_type.external_site_url}" unless event.event_type.external_site_url.to_s.empty?
    line = '<a '
    line += href
    line += " title=\"#{event.event_type.subtitle}\""
    line += ">#{event.event_type.name}</a><br/>"
    line += '<strong>CUPOS AGOTADOS</strong><br/>' if event.is_sold_out
    line += "#{event.specific_subtitle}<br/>" if event.specific_subtitle != ''
    line += if event.online?
              '<img src="/img/flags/ol.png"/> Online'
            elsif event.blended_learning?
              '<img src="/img/flags/ol.png"/> Online + Presencial'
            else
              "<img src=\"/img/flags/#{event.country_code.downcase}.png\"/> #{event.city}, #{event.country}"
            end
    result << line

    if registration_btn
      result << if event.is_sold_out
                  DTHelper.event_sold_out_link(i18n, locale)
                else
                  DTHelper.event_link(event, i18n, locale)
                end
    end

    result
  end

  def self.url_sanitize(data)
    %w[á a é e í i ó o ú u Á A É E Í I Ó O Ú U].each_slice(2) { |r| data.gsub!(r[0], r[1]) }
    data
  end

  def self.event_sold_out_link(i18n, locale)
    "<a href=\"javascript:void();\" target=\"_blank\" class=\"btn btn-danger\">#{i18n.t(
      'general.buttons.complete', locale: locale
    )}</a>"
  end

  def self.event_link(event, i18n, locale)
    button_text = i18n.t('general.buttons.i_am_interested', locale: locale)
    if event.registration_link != ''
      "<a href=\"#{event.registration_link}\" target=\"_blank\" class=\"btn btn-success btn-kleer\">#{button_text}</a>"
    else
      "<a data-toggle=\"modal\" data-target=\"#myModalRegistration\" href=\"/#{locale}/entrenamos/evento/#{event.id}/registration\" class=\"btn btn-info btn-kleer\">#{button_text}</a>"
    end
  end
end
