
let showFirst = 8
const container = document.getElementById('courses-container')
const categoryButtons = Array.from(document.getElementsByClassName('courses-filters__tag'))
const deliveryChecks = Array.from(document.getElementsByClassName('check-delivery'))
const seeMoreButton = document.getElementById("see-more")

let deliveryFilters = deliveryChecks.map(element => element.labels[0].outerText)
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
        deliveryOptions: getCourseCategory(element),
        name: name
    }
})


const compareCourse = (course) => {

    const deliveryCheck = deliveryFilters.some(item => {
        return course.deliveryOptions.includes(item)
    })
    const categoryCheck = categoryFilters.some(item => course.categories.includes(item))
    return deliveryCheck && categoryCheck
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

const handleClickCategory = (category) => {
    if(categoryFilters.includes(category)){
        categoryFilters = categoryFilters.filter(item => item !== category)
    }else{
        categoryFilters.push(category)
    }
    visualFilters()
}

const handleChangeDelivery = (type) => {
    if(deliveryFilters.includes(type)){
        deliveryFilters = deliveryFilters.filter(item => item !== type)
    }else{
        deliveryFilters.push(type)
    }
    visualFilters()
}

const handleClickSeeMore = () => {
    showFirst += 8
    visualFilters()
}

visualFilters()
