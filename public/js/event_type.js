var form = document.getElementById("event_type_contact_form");
form.addEventListener("submit", onSubmitForm);
function onSubmitForm(e) {
    e.preventDefault();
    var data = new FormData(form);
    fetch("/cursos/339/contact", { method: "POST", body: data });
    $('#event_type_contact').modal('hide');
    $('#contact_send').hide();
    $('#message').show();
}
