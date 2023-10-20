console.log('utils.js loaded')

window.addEventListener("hashchange", function () {
    console.log('hashchange')
    setTimeout(() => {
        window.scrollTo(window.scrollX, window.scrollY - 170);
    }, 1000)
});
