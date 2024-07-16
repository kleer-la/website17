class Pager
  attr_reader :item_per_page, :total, :page_number

  def initialize(item_per_page, total)
    @item_per_page = item_per_page
    @total = total
    @page_number = 0
  end

  def on_page(page_number)
    @page_number = [page_number, @total / @item_per_page].min
    self
  end

  def filter(list)
    list[(@page_number * @item_per_page)...(@page_number * @item_per_page) + @item_per_page]
  end

  def first?
    @page_number.zero?
  end

  def last?
    @page_number == ((@total - 1) / @item_per_page).to_i
  end

  def from_item
    (@page_number * @item_per_page) + 1
  end

  def to_item
    [(@page_number + 1) * @item_per_page,
     @total].min
  end
end
