DOMcourses = Array.from(document.getElementById('courses-container').children)

const activeCourses = []
let categoryInFilter = ''
let textInFilter = ''
let courses = []

const DOMobjects = {
    courses: {
        container: document.getElementById('training-courses__container'),
        list: Array.from(document.getElementById('courses-container').children),
        showMoreButton: document.getElementById('see-more'),
    },
    filterBox: {
        category: {
            drop: document.getElementById('catalog__category-drop'),
            setDropText: function(text) {
                this.drop.innerText = text ? text : 'Categorías'
            },
        },
        text: {
            input: document.getElementById('catalog__text-input'),
        },
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

const handleChangeText = (event) => {
    textInFilter = event ? event.target.value : ''
    filter()
}

const handleChangeCategory = (category) => {
    categoryInFilter = category
    // DOMobjects.showElements([DOMobjects.articles.title], false)
    DOMobjects.filterBox.category.setDropText(category)
    filter()
}

const handleShowAll = () => {
    courses.forEach(course => {
        course.card.classList.remove('hidden-element')
    })
    DOMobjects.showElements([DOMobjects.courses.showMoreButton], false)
}

const filter = () => {
    courses.forEach(course => {
        const hasCommonText = course.name.toLowerCase().includes(textInFilter.toLowerCase()) ||
            course.description.toLowerCase().includes(textInFilter.toLowerCase())
        let hasCommonCategory = true

        if(categoryInFilter){
            hasCommonCategory = course.categories.includes(categoryInFilter)
        }

        if(hasCommonText && hasCommonCategory){
            course.card.classList.remove('hidden-element')
        } else {
            course.card.classList.add('hidden-element')
        }
    })

    DOMobjects.showElements([DOMobjects.courses.showMoreButton], false)
}

const buildCoursesFromDOM = () => {
    courses = DOMcourses.map((element) => {
        let idSplitted = element.id.split('--')
        const plane_name= idSplitted.pop()
        const name = element.children[0].children[1].children[0].children[1].outerText
        const description = element.children[0].children[1].children[1].outerText

        return {
            card: element,
            categories: idSplitted,
            name,
            plane_name,
            description
        }
    })
}

const cleanAllFilters = () => {
    handleChangeCategory('')
    handleChangeText('')
    DOMobjects.filterBox.category.setDropText()
    DOMobjects.filterBox.text.input.value = ''
}

const setInitialPage = () => {
    courses.forEach((course, index) => {
        if(index < 8){
            course.card.classList.remove('hidden-element')
        }else{
            course.card.classList.add('hidden-element')
        }
    })
}

buildCoursesFromDOM()
setInitialPage()

