require './lib/toggle'
# Define las funciones accesibles en controllers y views

MONTHS_ES = { 'Jan' => 'Ene', 'Feb' => 'Feb', 'Mar' => 'Mar', 'Apr' => 'Abr', 'May' => 'May', 'Jun' => 'Jun',
              'Jul' => 'Jul', 'Aug' => 'Ago', 'Sep' => 'Sep', 'Oct' => 'Oct', 'Nov' => 'Nov', 'Dec' => 'Dic' }.freeze

module Helpers
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
end
