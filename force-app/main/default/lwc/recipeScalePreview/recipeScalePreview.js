import { LightningElement, api } from 'lwc';
import scaleRecipeForServings from '@salesforce/apex/RecipeController.scaleRecipeForServings';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Measurement', fieldName: 'Measurement__c', type: 'number' },
    { label: 'Unit', fieldName: 'Measurement_Type__c'},
    { label: 'Notes', fieldName: 'Notes__c'},
];

export default class RecipeScalePreview extends LightningElement {
    buttonDisabled = true;
    recipeId;
    recipeName;
    inputLabel;
    desiredServings;
    columns = columns;
    ingredients;
    error;

    @api 
    showScaling(recipeId, recipeName) {
        console.log('showscaling');
        console.log(recipeId);
        console.log(recipeName);
        this.recipeId = recipeId;
        this.recipeName = recipeName;
        this.inputLabel = 'Desired Servings For '+ this.recipeName;
    }

    handleServingChange(event) {
        this.desiredServings = event.detail.value;
        console.log(this.desiredServings);
        if (this.desiredServings>0) {
            this.buttonDisabled = false;
        } else {
            this.buttonDisabled = true;
        }
        
    }


    handleScaling(event) {
        console.log(this.desiredServings);
        scaleRecipeForServings({recipeId:this.recipeId, desiredServings:this.desiredServings})
            .then((result) => {
                console.log('result: '+result);
                this.ingredients = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.ingredients = undefined;
            });
    }

}