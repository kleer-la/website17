const DOMarticles = Array.from(document.getElementById('article-list').children)
const DOMarticlesSection = document.getElementById('articles')
const DOMselectedArticlesSection = document.getElementById('selected-articles')
const DOMtitle = document.getElementById('selected-articles__title')
const DOMpagingContainer = Array.from(document.getElementsByClassName('paging-container'))
const DOMcategoryDrop = document.getElementById('blog-feed__category-drop')
const DOMnextButtons = document.getElementsByClassName('next-button')
const DOMpreviousButtons = document.getElementsByClassName('prev-button')
const DOMpagerTexts = Array.from(document.getElementsByClassName('pager-text'))

let selectedArticles = []

const itemsPerPage = 9
const itemsInInitialPage = 6
let page = 1
let categoryInFilter = ''
let textInFilter = ''

const pager = {
    actualPage: 1,
    numberOfPages: 0,
    filteredArticlesCount: 0,
    filteredArticles: [],
    changePage: function(numberPage, items = itemsPerPage){
        this.actualPage = numberPage
        this.numberOfPages = Math.ceil(this.filteredArticles.length / items)
        const initialItem = (numberPage - 1) * items
        const finalItem = numberPage * items

        if(numberPage === 1){
            //disable previous button
        }else if(numberPage === this.numberOfPages){
            //disable next button
        }

        this.filteredArticles.forEach((article, index) => {
            console.log(article.name)
            if(index >= initialItem && index < finalItem){
                article.card.classList.remove('hidden-element')
            }else{
                article.card.classList.add('hidden-element')
            }
        })

        setPagerText(this.numberOfPages, this.actualPage)
    }
}

const setInitialPage = () => {
    showSelectedArticles(true)
    showPagingComponent(false)
    textInFilter = ''
    categoryInFilter = ''
    pager.changePage(1, itemsInInitialPage + selectedArticles.length)
}

const cleanAllFilters = () => {
    filterByCategory('')
    filterByText('')
    setInitialPage()
    DOMtitle.classList.remove('hidden-element')
    DOMtitle.innerHTML = `Lo mas nuevo`
}

const setPagerText = (numberOfPages, actualPage) => {
    let text = ``
    for(let i = 1; i <= numberOfPages; i++){
        if(i === actualPage){
            text += `<button onclick="pager.changePage(${i})"><b>${i}</b></button> `
        }else{
            text += `<button onclick="pager.changePage(${i})">${i}</button> `
        }
    }

    DOMpagerTexts.forEach(element => {
        element.innerHTML = text
    })
}

const showMore = () => {
    pager.changePage(1, itemsPerPage)
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

// const nextPage = () => {
//     const lastPage = Math.ceil(articles.length / itemsPerPage)
//     if(page === lastPage){
//         //disable next button
//     }else {
//         setPagination(page, itemsPerPage)
//     }
// }
//
// const previousPage = () => {
//     if(page > 1) {
//         setPagination(page, itemsPerPage)
//     }else {
//         //enable previous button
//     }
// }

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
    pager.filteredArticlesCount = 0
    pager.actualPage = 1
    pager.numberOfPages = 0

    articles.forEach(article => {
        if(categoryInFilter){
            if(article.category === categoryInFilter &&
                (article.title.toLowerCase().includes(textInFilter.toLowerCase()) ||
                    article.description.toLowerCase().includes(textInFilter.toLowerCase()))){

                article.card.classList.remove('hidden-element')
                pager.filteredArticlesCount++
            }else{
                article.card.classList.add('hidden-element')
            }
        }else{
            if(article.title.toLowerCase().includes(textInFilter.toLowerCase()) ||
                    article.description.toLowerCase().includes(textInFilter.toLowerCase())){

                article.card.classList.remove('hidden-element')
                pager.filteredArticlesCount++

            }else{
                article.card.classList.add('hidden-element')
            }
        }
    })

    pager.filteredArticles = articles.filter(article => !article.card.classList.contains('hidden-element'))
    console.log(pager.filteredArticles)
    showPagingComponent(true)
    pager.numberOfPages = Math.ceil(pager.filteredArticlesCount / itemsPerPage)
    pager.changePage(1, itemsPerPage)

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

//Impplementar en botones de categoria el action--/
//Implementar paginado a los botones con su inabilitacion
//implementar limpiar filtros
//Cambio de titulos
//implementar set params en la url


buildArticlesFromDOM()
setInitialPage()

