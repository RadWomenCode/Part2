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
		const recipeSelected = new CustomEvent('groceries', { detail: event.target.id });
        // Dispatches the event.
        this.dispatchEvent(recipeSelected);
	}
}