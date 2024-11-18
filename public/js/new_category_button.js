document.querySelector("#new-category").addEventListener('click', () => {
    category_selection = document.querySelector("#category_selection");
    
    category_text = document.createElement("input");
    category_text.setAttribute("type", "text");
    category_text.setAttribute("name", "category");
    category_text.setAttribute("required", "");

    category_selection.replaceWith(category_text);
});