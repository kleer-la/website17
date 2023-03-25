class BlogHomeData
  def initialize(articles, locale)
    @_filtered = @articles = articles.select { |a| a.lang == locale}
    @locale = locale
    @_selected = nil
  end
  def selected
    @_selected = @_selected || @articles.select{|e| e.selected}
  end
  def selected?
    selected.count > 0
  end
  def filter_by_text(text)
    if text
      @_filtered = @_filtered.select{|e| e.title.downcase.include?(text.downcase) }
    end
    self
  end
  def filter_by_category(category)
    if category
      @_filtered = @_filtered.select{|e| e.category_name == category}
    end
    self
  end
  def filtered(include_selected)
    if include_selected
      @_filtered
    else
      selected_slugs = selected.map(&:slug)
      @_filtered.reject{|e| selected_slugs.include? e.slug}
    end
  end
end

