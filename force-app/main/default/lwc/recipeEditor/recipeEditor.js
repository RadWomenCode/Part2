import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import addIngredient from "@salesforce/apex/RecipeController.addIngredient";

// These values must match the Measurement Type picklist on Ingredient__c.
// "value" is the picklist API name, "label" is what the user sees.
const MEASUREMENT_TYPE_OPTIONS = [
    { label: "Cups", value: "Cups" },
    { label: "Oz", value: "Oz" },
    { label: "Tbl", value: "Tbl" },
    { label: "Tsp", value: "Tsp" },
    { label: "Grams", value: "Grams" },
    { label: "Pound(s)", value: "Pounds" },
    { label: "Whole", value: "Whole" }
];

export default class RecipeEditor extends LightningElement {
    // Set by the parent component
    @api recipeId;
    @api recipeName;

    measurementTypeOptions = MEASUREMENT_TYPE_OPTIONS;

    // What the user has typed or picked so far
    ingredientName = "";
    measurement = "";
    measurementType = "";

    isSaving = false;

    // The button stays disabled until every field has a value
    get isAddDisabled() {
        return (
            !this.ingredientName ||
            !this.measurement ||
            !this.measurementType ||
            this.isSaving
        );
    }

    // ---------- Event handlers ----------

    handleNameChange(event) {
        this.ingredientName = event.detail.value;
    }

    handleMeasurementChange(event) {
        this.measurement = event.detail.value;
    }

    handleMeasurementTypeChange(event) {
        this.measurementType = event.detail.value;
    }

    async handleAddIngredient() {
        this.isSaving = true;

        try {
            await addIngredient({
                ingredientName: this.ingredientName,
                measurementAmount: Number(this.measurement),
                measurementType: this.measurementType,
                recipeId: this.recipeId
            });

            this.showToast(
                "Ingredient added",
                `Added ${this.ingredientName} to ${this.recipeName}.`,
                "success"
            );
            this.clearForm();

            // Tell the parent so it can refresh the grocery list
            this.dispatchEvent(new CustomEvent("ingredientadded"));
        } catch (error) {
            // Keep what the user typed so they can fix the problem and try again
            this.showToast(
                "Could not add ingredient",
                error.body?.message ?? "Unknown error.",
                "error"
            );
        } finally {
            this.isSaving = false;
        }
    }

    // ---------- Helpers ----------

    clearForm() {
        this.ingredientName = "";
        this.measurement = "";
        this.measurementType = "";
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
