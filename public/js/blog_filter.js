const DOMarticles = Array.from(document.getElementById('article-list').children)
const DOMtitle = document.getElementById('selected-articles__title')

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
            DOMobjects.showElements(DOMobjects.pager.previousButtons, false)
        }else if(numberPage === this.numberOfPages){
            DOMobjects.showElements(DOMobjects.pager.nextButtons, false)
        }else{
            DOMobjects.showElements(DOMobjects.pager.nextButtons, true)
            DOMobjects.showElements(DOMobjects.pager.previousButtons, true)
        }

        this.activeArticles.forEach((article, index) => {
            if(index >= initialItem && index < finalItem){
                article.card.classList.remove('hidden-element')
            }else{
                article.card.classList.add('hidden-element')
            }
        })

        DOMobjects.pager.setPagerText(this.numberOfPages, this.actualPage)
    }
}

const DOMobjects = {
    articles: {
        container: document.getElementById('articles'),
        list: Array.from(document.getElementById('article-list').children),
        title: document.getElementById('articles__title'),
        showMoreButton: document.getElementById('blog-feed-list__show-more-button'),
        setTitle: function(text){
            this.title.innerHTML = text
        },
    },
    selectedArticles: {
        container: document.getElementById('selected-articles'),
        list: document.getElementById('selected-articles'),
        title: document.getElementById('selected-articles__title'),
        show: function(show){

            if(selectedArticles.length > 0 && show){
                DOMobjects.showElements([this.container], true)
                selectedArticles.forEach(article => {
                    this.container.children[1].appendChild(article)
                    article.classList.remove('hidden-element')
                })
            }else{
                selectedArticles.forEach(article => {
                    DOMobjects.articles.container.children[2].prepend(article)
                })
                DOMobjects.showElements([this.container], false)
            }
        }
    },
    pager: {
        nextButtons: Array.from(document.getElementsByClassName('next-button')),
        previousButtons: Array.from(document.getElementsByClassName('prev-button')),
        pagerTexts: Array.from(document.getElementsByClassName('pager-text')),
        containers: Array.from(document.getElementsByClassName('paging-container')),
        setPagerText: function(numberOfPages, actualPage){
            let text = ``
            for(let i = 1; i <= numberOfPages; i++){
                if(i === actualPage){
                    text += `<button onclick="pager.changePage(${i})" class="clean-button"><b>${i}</b></button> `
                }else{
                    text += `<button onclick="pager.changePage(${i})" class="clean-button">${i}</button> `
                }
            }
            this.pagerTexts
                .forEach(element => {
                    element.innerHTML = text
                })
        }
    },
    filterBox: {
        category: {
            drop: document.getElementById('blog-feed__category-drop'),
            setDropText: function(text){
                this.drop.innerText = text ? text : 'Categorías'
            }
        },
        text: {
            input: document.getElementById('blog-feed__text-input'),
        }
    },
    showElements: function(elements, show){
        if(show){
            elements.forEach(element => {
                element.classList.remove('hidden-element')
            })
        }else{
            elements.forEach(element => {
                element.classList.add('hidden-element')
            })
        }
    }
}

const setInitialPage = () => {
    DOMobjects.showElements(DOMobjects.pager.containers, false)
    pager.activeArticles = articles.filter(article => !article.card.classList.contains('hidden-element'))

    textInFilter = ''
    categoryInFilter = ''

    let items = itemsInInitialPage

    pager.activeArticles.forEach((article, index) => {
        if(selectedArticles.includes(article.card)){
            items++;
        }

        if(index >= 0 && index < items){
            article.card.classList.remove('hidden-element')
        }else{
            article.card.classList.add('hidden-element')
        }
    })

    DOMobjects.selectedArticles.show(true)
}

const cleanAllFilters = () => {
    filterByCategory('')
    filterByText('')
    setInitialPage()
    DOMobjects.filterBox.text.input.value = ''
    DOMobjects.showElements([DOMobjects.articles.showMoreButton], true)
    DOMobjects.showElements([DOMobjects.selectedArticles.title], true)
    DOMobjects.showElements([DOMobjects.articles.title], true)
    DOMobjects.articles.setTitle(`Lo mas nuevo`)
}

const showMore = () => {
    DOMobjects.showElements(articles.map(e => e.card), true)
    DOMobjects.showElements(DOMobjects.pager.containers, true)
    DOMobjects.showElements([DOMobjects.articles.showMoreButton], false)
    DOMobjects.showElements([DOMobjects.articles.title], false)
    DOMobjects.selectedArticles.show(false)
    pager.changePage(1, itemsPerPage)
}

const nextPage = () => {
    pager.changePage(pager.actualPage + 1, itemsPerPage)
}

const previousPage = () => {
    pager.changePage(pager.actualPage - 1, itemsPerPage)
}


const filterByCategory = (category) => {
    categoryInFilter = category
    DOMobjects.selectedArticles.show(false)
    DOMobjects.showElements([DOMobjects.articles.title], false)
    DOMobjects.filterBox.category.setDropText(category)

    filter()
}

const filterByText = (event) => {
    const text = event ? event.target.value : ''
    textInFilter = text

    DOMtitle.classList.remove('hidden-element')
    DOMobjects.selectedArticles.show(false)
    DOMobjects.showElements([DOMobjects.articles.title], true)


    filter()

    if(text){
        DOMobjects.articles.setTitle(`${pager.filteredArticlesCount} resultados para: <b>${text}</b>`)
    }else{
        DOMobjects.showElements([DOMobjects.articles.title], false)
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
    DOMobjects.showElements(DOMobjects.pager.containers, true)
    DOMobjects.showElements([DOMobjects.articles.showMoreButton], false)
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


buildArticlesFromDOM()
setInitialPage()

