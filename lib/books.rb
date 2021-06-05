class Books
    def initialize
        @books= []
    end
    def all
        @books
    end
    def load
        # @books= [
        #     {   cover: "/img/ebooks/agile-team.jpg",
        #         title: "Agile Team Facilitator", #t.books.books.agile_team.title
        #         description: "Este libro es el primero de una serie que busca construir el camino de toda persona que quiera dedicarse al agile coaching. En esta edición el foco está en la facilitación de equipos, entendiendo las habilidades y responsabilidades que conlleva.",
        #                     # t.books.books.agile_team.text,
        #         landing: 'https://www.amazon.es/Agile-Team-Facilitator-Towards-Enterprise-ebook/dp/B018V9MQ30',
        #         button: "Obtener libro >>" #t.books.books.agile_team.next
        #     }
        # ]
        file = File.read('./lib/books_storage.json')
        @books= JSON.parse(file)['books']
        # p @books
        self
    end    
end