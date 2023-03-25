require './lib/articles'

require './controllers/blog_home_data'

describe BlogHomeData do
  context "empty list" do
    subject { BlogHomeData.new([], 'es') }
    
    it { expect(subject.filtered(true)).to be_empty }
    it { expect(subject.filtered(false)).to be_empty }
    # it { is_expected.to be_empty }
  end
  
  context "1 selected 2 total" do
    subject { 
      BlogHomeData.new( 
        Article.load_list([
          { 'title' => 'Lorem Ipsum',
            'lang' => 'es',
            'published' => true,
            'trainers' => [{ 'name' => 'Luke' }] },
          { 'title' => 'Dolor sit',
            'slug' => 'slug1',
            'lang' => 'es',
            'published' => true,
            'selected' => true,
            'trainers' => [{ 'name' => 'Luke' }] }
        ] ), 'es') 
    }
    
    it { expect(subject.selected?).to be true }
    it { expect(subject.selected[0].slug).to eq 'slug1' }
    it { expect(subject.filtered(false).count).to eq 1 }
    it { expect(subject.filtered(true).count).to eq 2 }
  end

end