import { LightningElement, api } from "lwc";
import scaleRecipeForServings from "@salesforce/apex/RecipeController.scaleRecipeForServings";

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

export default class RecipeScalePreview extends LightningElement {
    // Set by the parent component
    @api recipeName;

    columns = COLUMNS;

    desiredServings = "";
    scaledIngredients; // undefined until the user scales a recipe
    scaledServings; // the number of servings the current results are for
    errorMessage;
    isLoading = false;

    _recipeId;

    // When the parent switches to a different recipe, clear out the old results
    @api
    get recipeId() {
        return this._recipeId;
    }
    set recipeId(value) {
        this._recipeId = value;
        this.desiredServings = "";
        this.scaledIngredients = undefined;
        this.errorMessage = undefined;
    }

    // ---------- Getters used by the template ----------

    // The Scale button needs a number greater than zero
    get isScaleDisabled() {
        return !(Number(this.desiredServings) > 0) || this.isLoading;
    }

    get hasError() {
        return Boolean(this.errorMessage);
    }

    get hasResults() {
        return this.scaledIngredients?.length > 0;
    }

    get hasNoIngredients() {
        return this.scaledIngredients !== undefined && !this.hasResults;
    }

    get resultsHeading() {
        const unit = this.scaledServings === 1 ? "serving" : "servings";
        return `${this.recipeName} for ${this.scaledServings} ${unit}`;
    }

    // ---------- Event handlers ----------

    handleServingsChange(event) {
        this.desiredServings = event.detail.value;
    }

    async handleScale() {
        this.isLoading = true;
        this.errorMessage = undefined;

        try {
            const servings = Number(this.desiredServings);
            const result = await scaleRecipeForServings({
                recipeId: this._recipeId,
                desiredServings: servings
            });
            // Apex returns null until the method is implemented, so fall back to an empty list
            this.scaledIngredients = result ?? [];
            this.scaledServings = servings;
        } catch (error) {
            this.scaledIngredients = undefined;
            this.errorMessage = error.body?.message ?? "Unknown error.";
        } finally {
            this.isLoading = false;
        }
    }
}
