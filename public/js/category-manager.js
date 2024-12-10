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
        category_element.querySelector(".is-deleted-input").value = true;
        
        const category = category_element.querySelector(".category-options");
        category.style.background = "red";
        
        Array.from(category.getElementsByTagName('input')).forEach((element) => {element.disabled = true;});
        Array.from(category.getElementsByTagName('button')).forEach((element) => {
            if (element.className != "collapse-button") {
                element.style.display = "none";
            }
        });

        const subcategories = category_element.querySelector(".sub-categories"); 
        if (subcategories.children.length) {
           Array.from(subcategories.children).forEach((subcategory) => setDeleted(subcategory));
        }
    };

    const category = document.getElementById(id);
    setDeleted(category);
    category.querySelector(".undo-button").style.display = "inline-block"
    category.querySelector(".confirm-button").style.display = "inline-block"
};

confirmDeletion = (id) => {
    document.getElementById(id).style.display = "none";
};

undoDeletion = (id) => {
    undo = (category_element) =>  {
        category_element.querySelector(".is-deleted-input").value = false;
        
        const category = category_element.querySelector(".category-options");
        category.style.background = "";
        
        Array.from(category.getElementsByTagName('input')).forEach((element) => {element.disabled = false;});
        Array.from(category.getElementsByTagName('button')).forEach((element) => {
            if (element.className != "undo-button" && element.className != "confirm-button" && element.className != "set-parent-button") {
                element.style.display = "inline-block";
            }
            else {
                element.style.display = "none";
            }
        });

        const subcategories = category_element.querySelector(".sub-categories"); 
        if (subcategories.children.length) {
           Array.from(subcategories.children).forEach((subcategory) => undo(subcategory));
        }
    };

    undo(document.getElementById(id));
};

let child_to_append = null;
changeParent = (id) => {
    document.querySelectorAll('button').forEach((button) => {
        if (button.className == "set-parent-button") {
            button.style.display = "inline-block";
        }
        else {
            button.style.display = "none";
        }
    });

    child_to_append = document.getElementById(id);
};

setParent = (id) => {
    appendToParent(child_to_append, id);
    
    document.querySelectorAll('button').forEach((button) => {
        if (button.className == "set-parent-button" || button.className == "undo-button") {
            button.style.display = "none";
        }
        else {
            button.style.display = "";
        }
    });
};

appendToParent = (element, parent_id) => {
    element.querySelector(".parent-id-input").value = (parent_id == "categorylist-innercontainer") ? null : parent_id;
    
    parent_element_id = (!parent_id) ? "categorylist-innercontainer" : "subcategories-" + parent_id;

    document.getElementById(parent_element_id).appendChild(element);
}

instantiateCategory = (name, id, background_color, text_color) => {
    new_category = document.createElement('div');
    new_category.className = "categorylist-item";
    new_category.id = id;

    new_category.innerHTML = `
        <input type="text" class="parent-id-input" name="${id}#parent_id" style="display:none;">
        <input type="text" class="is-deleted-input" value="false" name="${id}#is_deleted" style="display:none;">
        <input type="text" class="is-new-input" value="false" name="${id}#is_new" style="display:none;">
        <div class="category-options">
            <div class="categorylist-item-left">
                <button class="collapse-button" type="button" onclick="collapse(this, '${id}')" collapsed="false">collapse</button>
                <span class="category-list-item-name"><label for="${id}#name" style="font-size: 0;">Category name</label><input type="text" name="${id}#name" id="${id}#name" required value="${name}"></span>
                <button type="button" class="set-parent-button" onclick="setParent('${id}')" style="display: none;">append</button>
                <button type="button" onclick="changeParent('${id}')">change parent</button>
                <button type="button" onclick="createCategory('${id}')">new child</button>
                <button type="button" class="delete-button" onclick="deleteCategory('${id}')">delete</button>
                <button type="button" class="undo-button" onclick="undoDeletion('${id}')" style="display: none;">undo</button>
                <button type="button" class="confirm-button" onclick="confirmDeletion('${id}')" style="display: none;">confirm</button>
            </div>
            <div class="categorylist-item-right">
                <span class="text-color-area">
                    <label for="${id}#text-color">Text-color:</label> <input type="color" name="${id}#text-color" id="${id}#text-color" value=${text_color}>
                </span>
                <span class="background-color-area">
                    <label for="${id}#background-color">Background-color:</label> <input type="color" name="${id}#background-color" id="${id}#background-color" value=${background_color}>
                </span>
            </div>
        </div>
        <div class="sub-categories" id="subcategories-${id}"></div>
    `;

    document.body.appendChild(new_category);

    return new_category;
};

let new_id_num = 0;
createCategory = (parent_id) => {
    new_category = instantiateCategory("", "new" + new_id_num++, 0, 0);
    appendToParent(new_category, parent_id);
    new_category.querySelector('.is-new-input').value = true;
};