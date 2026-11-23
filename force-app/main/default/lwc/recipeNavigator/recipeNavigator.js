import { LightningElement } from "lwc";

export default class RecipeNavigator extends LightningElement {
    // The recipe the user picked in the list
    selectedRecipeId;
    selectedRecipeName;

    get hasSelectedRecipe() {
        return Boolean(this.selectedRecipeId);
    }

    get cardTitle() {
        return this.selectedRecipeName ?? "Recipe Tools";
    }

    // The recipe list fires "recipeselect" when the user clicks a recipe.
    // We save the recipe here, and the template passes it down to the other components.
    handleRecipeSelect(event) {
        this.selectedRecipeId = event.detail.recipeId;
        this.selectedRecipeName = event.detail.recipeName;
    }

    // The recipe editor fires "ingredientadded" after saving.
    // The grocery list is now out of date, so ask it to reload.
    handleIngredientAdded() {
        this.refs.groceryList.refresh();
    }
}
