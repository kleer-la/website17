let showFirst = 8
const container = document.getElementById('courses-container')
const seeMoreButton = document.getElementById("see-more")

let categoryFilters = categoryButtons.map(element => element.outerText)

const getCourseCategory = (element) => {
    const divs = element.children[0].children[0].children[1].children;
    return Array.from(divs).map(div => div.outerText)
}

const courses = Array.from(container.children).map((element) => {
    let idSplitted = element.id.split('--')
    const name = idSplitted.pop()

    return {
        card: element,
        categories: idSplitted,
        name: name
    }
})

const compareCourse = (course) => {
    return categoryFilters.some(item => course.categories.includes(item))
}

const visualFilters = () => {
    let counter = 1
    courses.forEach((course, index) => {
        if(compareCourse(course) && counter <= showFirst){
            counter++
            course.card.classList.remove('hidden-element')
        }else{
            course.card.classList.add('hidden-element')
        }
    })

    if(showFirst >= courses.length){
        seeMoreButton.classList.add('hidden-element')
    }

    categoryButtons.forEach(button => {
        if(categoryFilters.includes(button.outerText)){
            button.classList.add('courses-filters__tag--selected')
            button.classList.remove('courses-filters__tag--unselected')
        }else{
            button.classList.remove('courses-filters__tag--selected')
            button.classList.add('courses-filters__tag--unselected')
        }
    })
}

const handleClickSeeMore = () => {
    showFirst += 8
    visualFilters()
}

//old filter refactored
const activeCourses = []
let categoryInFilter = ''
let textInFilter = ''

const DOMobjects = {
    courses: {
        container: '',
        list: '',
        showMoreButton: ''
    },
    filterBox: {
        category: {
            drop: '',
            setDropText: () => {},
        },
        text: {
            input: '',
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

}

const filterByText = (event) => {
    const text = event ? event.target.value : ''
    textInFilter = text

    filter()

    if(text){
        DOMobjects.courses.setTitle(`${pager.filteredArticlesCount} resultados para: <b>${text}</b>`)
    }else{
        DOMobjects.showElements([DOMobjects.articles.title], false)
    }
}

const filter = () => {
    courses.forEach(article => {
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
                pager.filteredArticlesCount++

            }else{
                article.card.classList.add('hidden-element')
            }
        }
    })

    pager.activeCourses = articles.filter(article => !article.card.classList.contains('hidden-element'))
    DOMobjects.showElements([DOMobjects.courses.showMoreButton], false)
}
