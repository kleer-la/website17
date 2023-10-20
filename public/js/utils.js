const anchors = document.querySelectorAll('a[href^="#"]')

anchors.forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();

        const targetId = this.getAttribute('href').substr(1);
        const navbarHeight = 160
        const targetElement = document.getElementById(targetId);

        if (targetElement) {
            const offset = targetElement.getBoundingClientRect().top - navbarHeight;

            window.scrollBy({
                top: offset,
                behavior: 'smooth'
            });
        }
    })
})

document.addEventListener('DOMContentLoaded', function () {
    if (window.location.hash) {
        const fragment = window.location.hash;
        window.location.hash = '';
        const targetElement = document.querySelector(fragment);
        if (targetElement){
            const offset = targetElement.getBoundingClientRect().top - 160;

            window.scrollBy({
                top: offset,
                behavior: 'smooth'
            })
        }
    }
});
