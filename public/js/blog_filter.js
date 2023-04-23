const DOMarticles = Array.from(document.getElementById('article-list').children)
let articles = []

let itemsPerPage = 6
let page = 1

const setArticles = () => {
    articles = DOMarticles.map((element) => {
        const cardElement = element.children[0]
        let idSplitted = cardElement.id.split('--')
        const name = idSplitted.pop()
        const category = idSplitted.pop()
        const title = cardElement.children[1].children[0].outerText
        const description = cardElement.children[1].children[2].outerText

        return {
            card: element,
            category,
            name,
            title,
            description
        }
    })
}

const filterByCategory = (category) => {
    if(category){
        articles.forEach(article => {
            if(article.category === category){
                article.card.classList.remove('hidden-element')
            }else{
                article.card.classList.add('hidden-element')
            }
        })
    }else{
        articles.forEach(article => {
            article.card.classList.remove('hidden-element')
        })
    }
}

const filterByText = (event) => {
    console.log("esta entrando")
    const text = event ? event.target.value : ''
    if(text){
        articles.forEach(article => {
            console.log(article.title.toLowerCase())
            console.log(text.toLowerCase())
            console.log(article.title.toLowerCase().includes(text.toLowerCase()))
            if(article.title.toLowerCase().includes(text.toLowerCase()) || article.description.toLowerCase().includes(text.toLowerCase())){
                article.card.classList.remove('hidden-element')
            }else{
                article.card.classList.add('hidden-element')
            }
        })
    }else{
        articles.forEach(article => {
            article.card.classList.remove('hidden-element')
        })
    }
}

const filter = () => {
    filterByCategory()
    filterByText()
}

setArticles()

