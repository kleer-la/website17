const itemsPerPage = 8

let page = 1
let textInFilter = ''
let resources = []

const pager = {
    actualPage: 1,
    numberOfPages: 0,
    filteredResourcesCount: 0,
    activeResources: [],
    changePage: function (numberPage, items = itemsPerPage){
        this.actualPage = numberPage
        this.numberOfPages = Math.ceil(this.activeResources.length / items)
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

        this.activeResources.forEach((resource, index) => {
            if(index >= initialItem && index < finalItem){
                resource.card.classList.remove('hidden-element')
            }else{
                resource.card.classList.add('hidden-element')
            }
        })

        localStorage.setItem('page', this.actualPage);
        DOMobjects.pager.setPagerText(this.numberOfPages, this.actualPage)
        addPageToLink()
    }
}

const DOMobjects = {
    resources: {
        list: Array.from(document.getElementById('resource-list').children),
        title: document.getElementById('search-title'),
        setTitle: function(text){
            this.title.innerHTML = text
        }
    },
    pager: {
        nextButtons: Array.from(document.getElementsByClassName('next-button')),
        previousButtons: Array.from(document.getElementsByClassName('prev-button')),
        pagerTexts: Array.from(document.getElementsByClassName('pager-text')),
        // containers: Array.from(document.getElementsByClassName('paging-container')),
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
        text: {
            input: document.getElementById('search-box__text-input'),
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
    textInFilter = ''
    pager.activeResources = resources.filter(resource => !resource.card.classList.contains('hidden-element'))
    pager.changePage(getInitialPage(), itemsPerPage)
}

const cleanAllFilters = () => {
    filterByText('')
    DOMobjects.filterBox.text.input.value = ''
}

const nextPage = () => {
    pager.changePage(pager.actualPage + 1, itemsPerPage)
}

const previousPage = () => {
    pager.changePage(pager.actualPage - 1, itemsPerPage)
}

const filterByText = (event) => {
    textInFilter = event ? event.target.value : ''

    // DOMtitle.classList.remove('hidden-element')
    // DOMobjects.showElements([DOMobjects.articles.title], true)


    filter()

    if(textInFilter){
        DOMobjects.showElements([DOMobjects.resources.title], true)
        DOMobjects.resources.setTitle(`${pager.filteredResourcesCount} resultados para: <b>${textInFilter}</b>`)
    }else{
        DOMobjects.showElements([DOMobjects.resources.title], false)
    }

}

const addPageToLink = () =>{
    let url = window.location.href
    url = new URL(url)

    if(url.searchParams.get('page')){
        url.searchParams.set('page', pager.actualPage)
    }else{
        url.searchParams.append('page', pager.actualPage)
    }


    history.pushState(null, null, url.toString())
}

const getPageOfResource = (resourceId) => {
    const resource = resources.find(resource => {
        return resource.id === resourceId
    })
    const index = pager.activeResources.indexOf(resource)
    return Math.ceil((index + 1) / itemsPerPage)
}

const getInitialPage = () => {
    const urlParams = new URLSearchParams(window.location.search)
    let pageInLink = parseInt(urlParams.get('page')) || 1
    const id = window.location.href.split('#')[1]

    return id ? getPageOfResource(id) : pageInLink
}

const filter = () => {
    pager.filteredResourcesCount = 0
    pager.actualPage = 1
    pager.numberOfPages = 0

    resources.forEach(resources => {
        if (resources.title.toLowerCase().includes(textInFilter.toLowerCase()) ||
            resources.description.toLowerCase().includes(textInFilter.toLowerCase())) {

            resources.card.classList.remove('hidden-element')
            pager.filteredResourcesCount++
        } else {
            resources.card.classList.add('hidden-element')
        }
    })

    pager.activeResources = resources.filter(resource => !resource.card.classList.contains('hidden-element'))
    pager.numberOfPages = Math.ceil(pager.activeResources.length / itemsPerPage)
    pager.changePage(1, itemsPerPage)
}

const buildResourcesFromDOM = () => {
    resources = DOMobjects.resources.list.map((element) => {
        const cardElement = element.children[0]
        const id = cardElement.id
        const title = cardElement.querySelector('.title').outerText
        const description = cardElement.querySelector('.subtitle').outerText

        return {
            card: element,
            title,
            id,
            description,
        }
    })
}

buildResourcesFromDOM()
setInitialPage()

