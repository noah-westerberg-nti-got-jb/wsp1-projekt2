const deadline_field = document.querySelector("#deadline-field");
    setDeadline = (switch_state) => {
        if (switch_state == true) {
            deadline_field.disabled = false;
        }
        else {
            deadline_field.disabled = true;
        }
    }
    document.querySelector("#deadline-switch").addEventListener('change', (e) => {setDeadline(e.target.checked);});
    setDeadline(document.querySelector("#deadline-switch").checked);