require './lib/toggle'
# Define las funciones accesibles en controllers y views

MONTHS_ES = { 'Jan' => 'Ene', 'Feb' => 'Feb', 'Mar' => 'Mar', 'Apr' => 'Abr', 'May' => 'May', 'Jun' => 'Jun',
              'Jul' => 'Jul', 'Aug' => 'Ago', 'Sep' => 'Sep', 'Oct' => 'Oct', 'Nov' => 'Nov', 'Dec' => 'Dic' }.freeze

module Helpers
  def format_date_range(start_date, finish_date, languaje)
    start_month = languaje == 'en' ? start_date.strftime("%d") : month_es(start_date.strftime("%b"))
    finish_month = languaje == 'en' ? finish_date.strftime("%d") : month_es(finish_date.strftime("%b"))

    if start_date == finish_date
      return "#{start_date.strftime("%d")} #{start_month}"
    end

    if start_month == finish_month
      "#{start_date.strftime("%d")} - #{finish_date.strftime("%d")}, #{start_month}"
    else
      "#{start_date.strftime("%d")} #{start_month} - #{finish_date.strftime("%d")} #{finish_month}"
    end
  end

  def format_categories(categories)
    categories_string = ""

    categories.each do |category|
      categories_string += "#{category}--"
    end

    return categories_string
  end

  def webp_ext(img_path)
    img_path[0..img_path.rindex('.')] + 'webp'
  end

  def month_es(month_en)
    MONTHS_ES[month_en]
  end

  def feature_on?(feature)
    Toggle.on?(feature)
  end

  def t(key, **ops)
    ops.merge!(locale: session[:locale])
    I18n.t(key, **ops)
  end

  def url_sanitize(data)
    # normalize to NFD, which separates every character into base character + diacritics, then remove diacritics
    data.unicode_normalize(:nfd).gsub(/\p{M}/, '')
  end

  def currency_symbol_for(iso_code)
    currency = Money::Currency.table[iso_code.downcase.to_sym] unless iso_code.nil?
    if currency.nil?
      ''
    else
      currency[:symbol]
    end
  end

  def money_format(amount)
    parts = amount.round(0).to_s.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1.')
    parts.join '.'
  end

  def external_url_anchor(url, attributes = '')
    "<a href=\"#{url}\" rel=\"noopener noreferrer\" target=\"_blank\" #{attributes}>"
  end

  # TODO: delete old
  def external_url_anchor2(url, attributes = '', text)
    "<a href=\"#{url}\" rel=\"noopener noreferrer\" target=\"_blank\" #{attributes}>#{text}</a>"
  end

  def media_url_anchor(url, attributes = '')
    "<a href=\"#{url}\" rel=\"noopener noreferrer\" target=\"_blank\" #{attributes}>"
  end

  # Translate keventer event to be shown in a course card
  def keventer_to_card(events, lang = 'es')
    events.map {|course|
      is_open = (course.date.to_s != '')
      # p "|#{course.date.class}|#{course.date.to_s}|#{is_open}"
      date = is_open ? format_date_range(course.date, course.finish_date, 'es') : '' #t('home2022.home_courses.no_date')
      is_incompany = true
      if course.event_type.lang == lang
        {
          title: course.event_type.name, duration: course.event_type.duration, subtitle: course.event_type.subtitle,
          cover: course.event_type.cover, uri_path: course.event_type.uri_path, open: false, date: date, url: "#{course.event_type.uri_path}",
          categories: format_categories(course.event_type.categories), is_open: is_open, is_incompany: is_incompany, is_elearning: false,
          country: 'OL', certified: (2 if course.event_type.is_sa_cert).to_i +
          (1 if course.event_type.is_kleer_cert).to_i,
        }
      end
    }.compact
  end

  def extract_titles(body)
    separator = '<h2>'
    item_separator = '</h2>'

    sec_separator = '<h3>'
    sec_item_separator = '</h3>'

    separated_titles= []

    titles = @markdown_renderer.render(body).split(separator)

    titles.each do |item|
      separated_item = item.split(item_separator)

      if separated_item[0].nil?
        next
      end

      if not separated_item[1].nil?
        sublist = separated_item[1].split(sec_separator)
        subtitles = []

        if sublist != [] or not sublist.nil?
          sublist.each do |subitem|
            subitem = subitem.split(sec_item_separator)

            if subitem[0].nil?
              next
            end

            subtitles.push(subitem[0])
          end
        end

        subtitles.shift
      end
      separated_titles.push({title: separated_item[0], subtitles: subtitles})
    end
    separated_titles.shift

    separated_titles
  end

  def set_ids_in_body(body, titles)
    plane_array = []

    titles.each.with_index do |title_hash, index|
      plane_array.push(
        string: "<h2>#{title_hash[:title]}</h2>",
        value: title_hash[:title],
        new_string: "<h2 id='title-#{index}'>#{title_hash[:title]}</h2>"
      )

      if title_hash[:subtitles]
        title_hash[:subtitles].each.with_index do |subtitle, sub_index|
          plane_array.push(
            string:"<h3>#{subtitle}</h3>",
            value: subtitle,
            new_string: "<h3 id='subtitle-#{index}-#{sub_index}'>#{subtitle}</h3>"
          )
        end
      end
    end

    plane_array.each do |item|
      body[item[:string]]= item[:new_string]
    end

    body
  end
end
