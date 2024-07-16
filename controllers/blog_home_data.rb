class BlogHomeData
  def initialize(articles, locale)
    @_filtered = @articles = articles.select { |a| a.lang == locale }.sort_by(&:created_at).reverse
    @locale = locale
    @_selected = nil
  end

  def selected
    @selected ||= @articles.select(&:selected)
  end

  def selected?
    selected.count.positive?
  end

  def filter_by_text(text)
    @_filtered = @_filtered.select { |e| e.title.downcase.include?(text.downcase) } if text
    self
  end

  def filter_by_category(category)
    @_filtered = @_filtered.select { |e| e.category_name == category } if category
    self
  end

  def filtered(include_selected)
    if include_selected
      @_filtered
    else
      selected_slugs = selected.map(&:slug)
      @_filtered.reject { |e| selected_slugs.include? e.slug }
    end
  end
end
