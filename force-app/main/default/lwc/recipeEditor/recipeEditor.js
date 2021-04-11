import { LightningElement, api } from 'lwc';
import addIngredient from '@salesforce/apex/RecipeController.addIngredient';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class RecipeEditor extends LightningElement {
    recipeName;
    recipeId;
    ingredientName;
    measurement;
    measurementType;


    @api 
    initializeEditor(recipeId, recipeName) {
        this.recipeId = recipeId;
        this.recipeName = recipeName;
            
    }

    get typeOptions() {
        return [
            { label: 'Cups', value: 'Cups' },
            { label: 'Oz', value: 'Oz' },
            { label: 'Tbl', value: 'Tbl' },
            { label: 'Tsp', value: 'Tsp' },
            { label: 'Grams', value: 'Grams' },
            { label: 'Pound(s)', value: 'Pounds' },
            { label: 'Whole', value: 'Whole' },
        ];
    }

    handleName(event) {
        this.ingredientName = event.detail.value;
    }

    handleMeasurement(event) {
        this.measurement = event.detail.value;
    }

    handleTypeChange(event) {
        this.measurementType = event.detail.value;
        
    }

    get saveDisabled() {
        if (this.ingredientName && this.measurement && this.measurementType) {
            return false;
        } else {
            return true;
        }
    }

    addIngredient() {
        addIngredient({ingredientName:this.ingredientName, measurementAmount:this.measurement, measurementType: this.measurementType, recipeId:this.recipeId})
            .then((result) => {
                // fire toast
                const event = new ShowToastEvent({
                    "title": "Success!",
                    "variant":"success",
                    "message": "Added " + this.ingredientName + " to " + this.recipeName + "!",
                });
                this.dispatchEvent(event);
                this.clearForm();
            })
            .catch((error) => {
                this.error = error;
                const event = new ShowToastEvent({
                    "title": "Error",
                    "variant":"error",
                    "message": "Thre was an error adding the ingredient "+ this.error,
                });
                this.dispatchEvent(event);
                this.clearForm();
            });
    }

    clearForm() {
        this.recipeName = null;
        this.recipeId = null;
        this.ingredientName = null;
        this.measurement = null;
        this.measurementType = null;
    }


}