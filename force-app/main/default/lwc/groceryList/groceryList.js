import { LightningElement, api } from 'lwc';

import generateGroceryList from '@salesforce/apex/RecipeController.generateGroceryList';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Measurement', fieldName: 'Measurement__c', type: 'number' },
    { label: 'Unit', fieldName: 'Measurement_Type__c'},
    { label: 'Notes', fieldName: 'Notes__c'},
];

export default class GroceryList extends LightningElement {
    columns = columns;
    ingredients;
    error;
    
    @api 
    loadGroceries(recipeId) {
        generateGroceryList({recipeId:recipeId})
            .then((result) => {
                this.ingredients = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.ingredients = undefined;
            });
    }

}