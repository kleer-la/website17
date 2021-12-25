require './lib/toggle'
# Define las funciones accesibles en controllers y views

MONTHS_ES = { 'Jan' => 'Ene', 'Feb' => 'Feb', 'Mar' => 'Mar', 'Apr' => 'Abr', 'May' => 'May', 'Jun' => 'Jun',
  'Jul' => 'Jul', 'Aug' => 'Ago', 'Sep' => 'Sep', 'Oct' => 'Oct', 'Nov' => 'Nov', 'Dec' => 'Dic' }.freeze

helpers do
  def month_es(month_en)
    MONTHS_ES[month_en]
  end

  def feature_on?(feature)
    Toggle.on?(feature)
  end

  def t(key, ops = {})
    ops.merge!(locale: session[:locale])
    I18n.t key, ops
  end

  def url_sanitize(data)
    sanitized = data
    sanitized = sanitized.gsub('á', 'a')
    sanitized = sanitized.gsub('é', 'e')
    sanitized = sanitized.gsub('í', 'i')
    sanitized = sanitized.gsub('ó', 'o')
    sanitized = sanitized.gsub('ú', 'u')
    sanitized = sanitized.gsub('Á', 'A')
    sanitized = sanitized.gsub('E', 'E')
    sanitized = sanitized.gsub('Í', 'I')
    sanitized = sanitized.gsub('Ó', 'O')
    sanitized.gsub('Ú', 'U')
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

  def external_url_anchor(url)
    "<a href=\"#{url}\" rel=\"noopener noreferrer\" target=\"_blank\">"
  end
  def media_url_anchor(url)
    "<a href=\"#{url}\" rel=\"noopener noreferrer\" target=\"_blank\">"
  end
end
