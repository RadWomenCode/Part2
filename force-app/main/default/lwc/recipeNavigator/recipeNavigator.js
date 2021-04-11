import { LightningElement } from 'lwc';

export default class RecipeNavigator extends LightningElement {

    handleGroceries(event) {
        // Call the method on our grocery list component and pass in the selected recipe ID
        this.template.querySelector('c-grocery-list').loadGroceries(event.detail);
    }

    handleIngredients(event) {
        // Call the method on our recipe editor and pass in the selected recipe ID and name
        this.template.querySelector('c-recipe-editor').initializeEditor(event.detail.recipeId, event.detail.recipeName);
    }

    handleScaling(event) {
        this.template.querySelector('c-recipe-scale-preview').showScaling(event.detail.recipeId, event.detail.recipeName);
    }
}