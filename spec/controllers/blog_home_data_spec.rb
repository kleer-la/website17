require './controllers/blog_home_data'

describe BlogHomeData do
  context "empty list" do
    subject { BlogHomeData.new([], 'es') }
    
    it { expect(subject.filtered(true)).to be_empty }
    it { expect(subject.filtered(false)).to be_empty }
    # it { is_expected.to be_empty }
  end
  

end