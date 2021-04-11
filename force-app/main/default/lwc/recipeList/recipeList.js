// Adapted from the Trailhead Bear Tracking App  https://github.com/trailheadapps/build-apps-with-lwc

import { LightningElement, wire } from 'lwc';
import BOOK_IMG from '@salesforce/resourceUrl/CookbookSilhouette';

/** RecipeController.searchRecipes(searchTerm) Apex method */
import searchRecipes from '@salesforce/apex/RecipeController.searchRecipes';
export default class recipeList extends LightningElement {
    // Expose the static resource URL for use in the template
    bookSilhouette = BOOK_IMG;

	searchTerm = '';
	@wire(searchRecipes, {searchTerm: '$searchTerm'})
	recipes = [];

	handleSearchTermChange(event) {
		// Debouncing this method: do not update the reactive property as
		// long as this function is being called within a delay of 300 ms.
		// This is to avoid a very large number of Apex method calls.
		window.clearTimeout(this.delayTimeout);
		const searchTerm = event.target.value;
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this.delayTimeout = setTimeout(() => {
			this.searchTerm = searchTerm;
		}, 300);
	}
	get hasResults() {
		return (this.recipes.data.length > 0);
	}


	handleGroceryList(event) {
		console.log('handleGroceryList');
		// Get just the 18 digit ID
        let recipeId = event.target.id.substring(0, 18);
		const recipeSelected = new CustomEvent('groceries', { detail: recipeId });
        // Dispatches the event.
        this.dispatchEvent(recipeSelected);
	}

	handleEditIngredients(event) {
		let recipeId = event.target.id.substring(0, 18);
		let recipeName = this.getRecipeName(recipeId);

		const loadIngEditor = new CustomEvent('ingredients', { 
			detail: {
				recipeId:recipeId, 
				recipeName:recipeName }
			});
        // Dispatches the event.
        this.dispatchEvent(loadIngEditor);

	}

	loadScaling (event) {
		console.log('load scaling');
		let recipeId = event.target.id.substring(0, 18);
		let recipeName = this.getRecipeName(recipeId);

		const showScaled = new CustomEvent('scale', { 
			detail: {
				recipeId:recipeId, 
				recipeName:recipeName }
			});
        // Dispatches the event.
        this.dispatchEvent(showScaled);
	}

	getRecipeName(id) {
		for (let r of this.recipes.data) {
			// Get just the 18 digit ID
			if (r.Id===id) {
				return r.Name;
			}
		}
	}

}