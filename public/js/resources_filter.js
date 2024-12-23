const itemsPerPage = 16

let page = 1
let textInFilter = ''
let resources = []

const pager = {
    actualPage: 1,
    numberOfPages: 0,
    filteredResourcesCount: 0,
    activeResources: [],
    changePage: function (numberPage, items = itemsPerPage){
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

  // Just show/hide based on filter, no paging involved
  resources.forEach(resource => {
      if (textInFilter === '' || // Show all if no filter text
          resource.title.toLowerCase().includes(textInFilter.toLowerCase()) ||
          resource.description.toLowerCase().includes(textInFilter.toLowerCase())) {

          resource.card.classList.remove('hidden-element')
          pager.filteredResourcesCount++
      } else {
          resource.card.classList.add('hidden-element')
      }
  })

  if(textInFilter) {
      DOMobjects.showElements([DOMobjects.resources.title], true)
      DOMobjects.resources.setTitle(`${pager.filteredResourcesCount} resultados para: <b>${textInFilter}</b>`)
  } else {
      DOMobjects.showElements([DOMobjects.resources.title], false)
  }
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
resources.forEach(resource => {
  resource.card.classList.remove('hidden-element') // Show all initially
})
setInitialPage()