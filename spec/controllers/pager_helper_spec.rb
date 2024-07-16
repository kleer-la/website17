require './controllers/pager_helper'

describe Pager do
  context 'initialize' do
    subject { Pager.new(4, 3) }

    it { expect(subject.first?).to be true }
    it { expect(subject.last?).to be true }
  end
  context '10 items / 4 x page (first/last)' do
    subject(:first_page) { Pager.new(4, 10) }
    subject(:second_page) { Pager.new(4, 10).on_page(1) }
    subject(:third_page) { Pager.new(4, 10).on_page(2)  }

    it { expect(first_page.first?).to be true }
    it { expect(first_page.last?).to be false }
    it { expect(second_page.first?).to be false }
    it { expect(second_page.last?).to be false }
    it { expect(third_page.first?).to be false }
    it { expect(third_page.last?).to be true }
  end
end
