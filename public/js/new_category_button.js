const category_switch = document.querySelector("#category-switch");
let switch_state = true

const category_list_container = document.querySelector("#category-list");
const category_list = category_list_container.firstElementChild;

const new_category_container = document.querySelector("#new-category");
const new_category = new_category_container.firstElementChild;

document.querySelector("#category-switch").addEventListener('click', () => {
    switch_state = !switch_state;

    if (switch_state) {
        category_list_container.style.display = "";
        category_list.required = true;
        category_list.name = "category";

        new_category_container.style.display = "none";
        new_category.required = false;
        new_category.name = false;

        category_switch.innerHTML = "+"
    }
    else {
        category_list_container.style.display = "none";
        category_list.required = false;
        category_list.name = false;

        new_category_container.style.display = "";
        new_category.required = true;
        new_category.name = "category";

        category_switch.innerHTML = "-"
    }
});