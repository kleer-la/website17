require './lib/books'

describe Books do
    it 'empty' do
        books= Books.new
        expect(books.all).to eq []
    end
    it 'read books' do
        books= Books.new
        books.load
        expect(books.all.count).to be > 0        
    end
    it 'a book has sp title' do
        book= (Books.new).load.all[0]
        expect(book['es']['title'].length).to be > 0
    end

end