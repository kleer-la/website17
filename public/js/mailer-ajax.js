const button = document.getElementById('mail-modal-button');
const modalBody = document.getElementById('modal-mail-body');

button.addEventListener('click', async () => {
    const response = await fetch('/mailer-template')
    modalBody.innerHTML = await response.text()
})
