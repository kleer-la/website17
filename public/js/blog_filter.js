const DOMarticles = Array.from(document.getElementById('article-list').children)
const DOMarticlesSection = document.getElementById('articles')
const DOMselectedArticlesSection = document.getElementById('selected-articles')
const DOMtitle = document.getElementById('selected-articles__title')
const DOMpagingContainer = Array.from(document.getElementsByClassName('paging-container'))
const DOMcategoryDrop = document.getElementById('blog-feed__category-drop')
let selectedArticles = []

const itemsPerPage = 9
const itemsInInitialPage = 6
let page = 1
let categoryInFilter = ''
let textInFilter = ''

const setInitialPage = () => {
    setPagination(1, itemsInInitialPage + selectedArticles.length)
    showSelectedArticles(true)
    showPagingComponent(false)
    textInFilter = ''
    categoryInFilter = ''
}

const showMore = () => {
    setPagination(1, itemsPerPage)
    showSelectedArticles(false)
    showPagingComponent(true)
    DOMtitle.classList.add('hidden-element')
}

const showPagingComponent = (show) => {
    if(show){
        DOMpagingContainer.forEach(element => {
            element.classList.remove('hidden-element')
        })
    }else{
        DOMpagingContainer.forEach(element => {
            element.classList.add('hidden-element')
        })
    }
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

const nextPage = () => {
    const lastPage = Math.ceil(articles.length / itemsPerPage)
    if(page === lastPage){
        //disable next button
    }else {
        page++
        setPagination(page, itemsPerPage)
    }
}

const previousPage = () => {
    if(page > 1) {
        page--
        setPagination(page, itemsPerPage)
    }else {
        //enable previous button
    }
}

const showSelectedArticles = (show) => {
    if(selectedArticles.length > 0 && show){
        DOMselectedArticlesSection.classList.remove('hidden-element')
        selectedArticles.forEach(article => {
            DOMselectedArticlesSection.children[1].appendChild(article)
        })
    }else{
        selectedArticles.forEach(article => {
            DOMarticlesSection.children[2].prepend(article)
        })
        DOMselectedArticlesSection.classList.add('hidden-element')
    }
}

const buildArticlesFromDOM = () => {
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
    categoryInFilter = category
    showSelectedArticles(false)
    DOMcategoryDrop.innerText = category ? category : 'Categorías'
    filter()
}

const filterByText = (event) => {
    const text = event ? event.target.value : ''
    textInFilter = text

    DOMtitle.classList.remove('hidden-element')
    showSelectedArticles(false)
    filter()

    if(text){
        DOMtitle.innerHTML =`Resultados de búsqueda para: <b>${text}</b>`
    }else{
        DOMtitle.classList.add('hidden-element')
    }

}

const filter = () => {
    articles.forEach(article => {
        if(categoryInFilter){
            if(article.category === categoryInFilter &&
                (article.title.toLowerCase().includes(textInFilter.toLowerCase()) ||
                    article.description.toLowerCase().includes(textInFilter.toLowerCase()))){
                article.card.classList.remove('hidden-element')
            }else{
                article.card.classList.add('hidden-element')
            }
        }else{
            if(article.title.toLowerCase().includes(textInFilter.toLowerCase()) ||
                    article.description.toLowerCase().includes(textInFilter.toLowerCase())){

                article.card.classList.remove('hidden-element')
            }else{
                article.card.classList.add('hidden-element')
            }
        }
    })
}

//Impplementar en botones de categoria el action--/
//Implementar paginado a los botones con su inabilitacion
//implementar limpiar filtros
//Cambio de titulos
//implementar set params en la url


buildArticlesFromDOM()
setInitialPage()

