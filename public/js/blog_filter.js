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
    activeArticles: [],
    changePage: function(numberPage, items = itemsPerPage){
        this.actualPage = numberPage
        this.numberOfPages = Math.ceil(this.activeArticles.length / items)
        const initialItem = (numberPage - 1) * items
        const finalItem = numberPage * items

        if(numberPage === 1){
            //disable previous button
        }else if(numberPage === this.numberOfPages){
            //disable next button
        }
        console.log(this.activeArticles)

        this.activeArticles.forEach((article, index) => {
            console.log(article.name)
            if(index >= initialItem && index < finalItem){
                console.log('show')
                article.card.classList.remove('hidden-element')
            }else{
                console.log('hide')
                article.card.classList.add('hidden-element')
            }
        })

        setPagerText(this.numberOfPages, this.actualPage)
    }
}
const DOMobjects = {
    articles: {
        container: document.getElementById('articles'),
        list: Array.from(document.getElementById('article-list').children),
        title: null
    },
    selectedArticles: {
        container: null,
        list: document.getElementById('selected-articles'),
        title: document.getElementById('selected-articles__title'),
        setTitle: function(text){}
    },
    pager: {
        nextButtons: Array.from(document.getElementsByClassName('next-button')),
        previousButtons: Array.from(document.getElementsByClassName('prev-button')),
        pagerTexts: Array.from(document.getElementsByClassName('pager-text')),
        container: Array.from(document.getElementsByClassName('paging-container')),
        showPager: function(show){
            if(show){
                this.container.forEach(element => {
                    element.classList.remove('hidden-element')
                })
            }else{
                this.container.forEach(element => {
                    element.classList.add('hidden-element')
                })
            }
        }
    },
    filterBox: {
        category: {
            drop: document.getElementById('blog-feed__category-drop'),
        },
        text: {}
    },

}

// const filter = {}

const setInitialPage = () => {
    showSelectedArticles(true)
    DOMobjects.pager.showPager(false)
    pager.activeArticles = articles.filter(article => !article.card.classList.contains('hidden-element'))

    textInFilter = ''
    categoryInFilter = ''
    pager.changePage(1, itemsInInitialPage + selectedArticles.length)
}

const cleanAllFilters = () => {
    filterByCategory('')
    filterByText('')
    setInitialPage()

    DOMobjects.selectedArticles.title
        .classList.remove('hidden-element')
    DOMobjects.selectedArticles.title
        .innerHTML = `Lo mas nuevo`
}

//TODO: va al objeto
const setPagerText = (numberOfPages, actualPage) => {
    let text = ``
    for(let i = 1; i <= numberOfPages; i++){
        if(i === actualPage){
            text += `<button onclick="pager.changePage(${i})"><b>${i}</b></button> `
        }else{
            text += `<button onclick="pager.changePage(${i})">${i}</button> `
        }
    }

    DOMobjects.pager.pagerTexts
        .forEach(element => {
        element.innerHTML = text
    })
}

const showMore = () => {
    articles.forEach(article => {
        article.card.classList.remove('hidden-element')
    })

    showSelectedArticles(false)
    DOMobjects.pager.showPager(true)
    pager.changePage(1, itemsPerPage)
    DOMtitle.classList.add('hidden-element')
}

// const showPagingComponent = (show) => {
//     if(show){
//         DOMpagingContainer.forEach(element => {
//             element.classList.remove('hidden-element')
//         })
//     }else{
//         DOMpagingContainer.forEach(element => {
//             element.classList.add('hidden-element')
//         })
//     }
// }

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
    pager.activeArticles = articles.filter(article => !article.card.classList.contains('hidden-element'))

    DOMobjects.pager.showPager(true)

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

