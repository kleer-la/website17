require './lib/resources'

describe Resources do
    it 'empty' do
        resources= Resources.new
        expect(resources.all).to eq []
    end
    it 'read books' do
        resources= Resources.new
        resources.load
        expect(resources.all.count).to be > 0        
    end
    it 'a book has es title' do
        resource= (Resources.new).load.all[0]
        expect(resource['es']['title'].length).to be > 0
    end
    it 'each es book has en counterpart' do
        resource= (Resources.new).load.all[0]
        expect(resource['es']).to eq resource['en']
    end

end