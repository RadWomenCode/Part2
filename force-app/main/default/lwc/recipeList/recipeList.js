import { LightningElement, wire } from "lwc";
import searchRecipes from "@salesforce/apex/RecipeController.searchRecipes";

// How long to wait after the user stops typing before we search (in milliseconds)
const SEARCH_DELAY_MS = 300;

// Shorter labels for the Active Time Units picklist values
const TIME_UNIT_LABELS = { Minutes: "min", Hours: "hr" };

export default class RecipeList extends LightningElement {
    searchTerm = "";
    selectedRecipeId;
    searchTimeout;

    // Calls RecipeController.searchRecipes and runs it again whenever searchTerm changes.
    // The '$' in '$searchTerm' tells LWC to watch that property.
    // The result is an object with two properties: data (the recipes) and error.
    @wire(searchRecipes, { searchTerm: "$searchTerm" })
    recipes;

    // ---------- Getters used by the template ----------

    get hasError() {
        return Boolean(this.recipes.error);
    }

    get errorMessage() {
        return this.recipes.error?.body?.message;
    }

    // True until the first response (data or error) comes back
    get isLoading() {
        return !this.recipes.data && !this.recipes.error;
    }

    get hasRecipes() {
        return this.recipes.data?.length > 0;
    }

    get resultsSummary() {
        const count = this.recipes.data.length;
        return `${count} ${count === 1 ? "recipe" : "recipes"}`;
    }

    // Turns each Recipe__c record into a simple object the template can display
    get recipeTiles() {
        return this.recipes.data.map((recipe) => {
            return {
                id: recipe.Id,
                name: recipe.Name,
                complexity: recipe.Complexity__c,
                season: recipe.Season__c,
                activeTime: this.formatActiveTime(recipe),
                isSelected: recipe.Id === this.selectedRecipeId
            };
        });
    }

    // ---------- Event handlers ----------

    handleSearchChange(event) {
        const newSearchTerm = event.target.value;

        // Wait for the user to pause typing, so we don't call Apex on every keystroke
        clearTimeout(this.searchTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimeout = setTimeout(() => {
            this.searchTerm = newSearchTerm;
        }, SEARCH_DELAY_MS);
    }

    handleRecipeClick(event) {
        // The id comes from the data-recipe-id attribute on the clicked button
        const recipeId = event.currentTarget.dataset.recipeId;
        const recipe = this.recipes.data.find((item) => item.Id === recipeId);

        this.selectedRecipeId = recipeId;

        // Tell the parent component which recipe was picked
        this.dispatchEvent(
            new CustomEvent("recipeselect", {
                detail: { recipeId, recipeName: recipe.Name }
            })
        );
    }

    // ---------- Helpers ----------

    formatActiveTime(recipe) {
        if (!recipe.Active_Time__c) {
            return "";
        }
        const unit =
            TIME_UNIT_LABELS[recipe.Active_Time_Units__c] ??
            recipe.Active_Time_Units__c ??
            "";
        return `${recipe.Active_Time__c} ${unit}`.trim();
    }
}
