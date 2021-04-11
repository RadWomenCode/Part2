import { LightningElement } from 'lwc';

export default class RecipeNavigator extends LightningElement {

    handleGroceries(event) {
        // Get just the 18 digit ID
        let recipeId = event.detail.substring(0, 18);
        // Call the method on our grocery list component and pass in the selected recipe ID
        this.template.querySelector('c-grocery-list').loadGroceries(recipeId);
    }
}