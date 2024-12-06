collapse = (button, id) => {
    if (button.collapsed) {
        document.getElementById("subcategories-" + id).style.display = "block";
        button.innerHTML = "collapse";
    } 
    else {
        document.getElementById("subcategories-" + id).style.display = "none";
        button.innerHTML = "expand";
    }
    button.collapsed = !button.collapsed
};

deleteCategory = (id) => {
    setDeleted = (category_element) =>  {
        category_element.deleted = true;
        
        const category = category_element.children[0];
        category.style.background = "red";
        
        disable = (element) => {element.disabled = true;};
        Array.from(category.getElementsByTagName('input')).forEach((element) => disable(element));
        Array.from(category.getElementsByTagName('button')).forEach((element) => disable(element));

        const subcategories = category_element.children[1]; 
        if (subcategories.children.length) {
           Array.from(subcategories.children).forEach((subcategory) => setDeleted(subcategory));
        }
    };

    setDeleted(document.getElementById(id));
};

let child_to_append = null;
changeParent = (id) => {
    document.querySelectorAll('button').forEach((button) => {
        if (button.className == "set-parent-button") {
            button.style.display = "";
        }
        else {
            button.style.display = "none";
        }
    });

    child_to_append = document.getElementById(id);
};

setParent = (id) => {
    const append_id = (id == null) ? "categorylist-innercontainer" : "subcategories-" + id;
    document.getElementById(append_id).appendChild(child_to_append);
    
    document.querySelectorAll('button').forEach((button) => {
        if (button.className == "set-parent-button") {
            button.style.display = "none";
        }
        else {
            button.style.display = "";
        }
    });
};

let new_id_num = 0;
createCategory = (parent_id) => {
    new_category = document.createElement('div');
    new_category.className= "categorylist-item";
    const id = "new" + new_id_num++;
    new_category.id = id;

    new_category.innerHTML = `
        <div class="category-options">
            <div class="categorylist-item-left">
                <button type="button" onclick="collapse(this, '${id}')" collapsed="false">collapse</button>
                <span class="category-list-item-name"><input type="text" required></span>
                <button type="button" class="set-parent-button" onclick="setParent('${id}')" style="display: none;">append</button>
                <button type="button" onclick="changeParent('${id}')">change parent</button>
                <button type="button" onclick="createCategory('${id}')">new child</button>
                <button type="button" id="delete-button" onclick="deleteCategory('${id}')">delete</button>
            </div>
            <div class="categorylist-item-right">
                <span class="text-color-area">
                    Text-color: <input type="color">
                </span>
                <span class="background-color-area">
                    Background-color: <input type="color">
                </span>
            </div>
        </div>
        <div class="sub-categories" id="subcategories-${id}"></div>
    `;

    parent_element_id = (parent_id == null) ? "categorylist-innercontainer" : "subcategories-" + parent_id;
    document.getElementById(parent_element_id).appendChild(new_category);
};