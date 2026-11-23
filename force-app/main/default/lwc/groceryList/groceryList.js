import { LightningElement, api } from "lwc";
import generateGroceryList from "@salesforce/apex/RecipeController.generateGroceryList";

// Columns for the table: each one points at a field on Ingredient__c
const COLUMNS = [
    { label: "Ingredient", fieldName: "Name" },
    {
        label: "Amount",
        fieldName: "Measurement__c",
        type: "number",
        typeAttributes: { maximumFractionDigits: 2 },
        cellAttributes: { alignment: "left" }
    },
    { label: "Unit", fieldName: "Measurement_Type__c" },
    { label: "Notes", fieldName: "Notes__c", wrapText: true }
];

export default class GroceryList extends LightningElement {
    columns = COLUMNS;
    ingredients = [];
    errorMessage;
    isLoading = false;

    _recipeId;

    // The parent sets recipeId. Each time it changes, we load that recipe's ingredients.
    @api
    get recipeId() {
        return this._recipeId;
    }
    set recipeId(value) {
        this._recipeId = value;
        this.loadIngredients();
    }

    // The parent can call this to reload the list (for example after adding an ingredient)
    @api
    refresh() {
        return this.loadIngredients();
    }

    // ---------- Getters used by the template ----------

    get hasError() {
        return Boolean(this.errorMessage);
    }

    get hasIngredients() {
        return this.ingredients.length > 0;
    }

    get showEmptyState() {
        return !this.isLoading && !this.hasError && !this.hasIngredients;
    }

    // ---------- Load data from Apex ----------

    async loadIngredients() {
        if (!this._recipeId) {
            return;
        }

        this.isLoading = true;
        this.errorMessage = undefined;

        try {
            const result = await generateGroceryList({
                recipeId: this._recipeId
            });
            // Apex returns null until the method is implemented, so fall back to an empty list
            this.ingredients = result ?? [];
        } catch (error) {
            this.ingredients = [];
            this.errorMessage = error.body?.message ?? "Unknown error.";
        } finally {
            this.isLoading = false;
        }
    }
}
