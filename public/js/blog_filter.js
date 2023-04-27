const DOMarticles = Array.from(document.getElementById('article-list').children)
const DOMarticlesSection = document.getElementById('articles')
const selectedArticlesSection = document.getElementById('selected-articles')
const DOMtitle = document.getElementById('selected-articles__title')
let articles = []
let selectedArticles = []

const itemsPerPage = 9
const itemsInInitialPage = 6
let page = 1

const setInitialPage = () => {
    setPagination(1, itemsInInitialPage + selectedArticles.length)
    showSelectedArticles(true)
}

const showMore = () => {
    setPagination(1, itemsPerPage)
    showSelectedArticles(false)
    DOMtitle.classList.add('hidden-element')
}

const setPagination = (numberPage, items) => {
    const initialItem = (numberPage - 1) * items
    const finalItem = numberPage * items

    articles.forEach((article, index) => {
        if(index >= initialItem && index < finalItem){
            article.card.classList.remove('hidden-element')
        }else{
            article.card.classList.add('hidden-element')
        }
    })
}

const showSelectedArticles = (show) => {
    if(selectedArticles.length > 0 && show){
        selectedArticlesSection.classList.remove('hidden-element')
        selectedArticles.forEach(article => {
            selectedArticlesSection.children[1].appendChild(article)
        })
    }else{
        selectedArticles.forEach(article => {
            DOMarticlesSection.children[1].prepend(article)
        })
        selectedArticlesSection.classList.add('hidden-element')
    }
}

const setArticles = () => {
    articles = DOMarticles.map((element) => {
        const cardElement = element.children[0]
        let idSplitted = cardElement.id.split('--')
        const name = idSplitted.pop()
        const category = idSplitted.pop()
        const title = cardElement.children[1].children[0].outerText
        const description = cardElement.children[1].children[2].outerText
        const selected = idSplitted.shift().split('-').pop() === 'selected'

        if(selected){
            selectedArticles.push(element)
        }

        return {
            card: element,
            category,
            name,
            title,
            description,
            selected
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
    const text = event ? event.target.value : ''
    if(text){
        articles.forEach(article => {
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
setInitialPage()

