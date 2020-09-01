public with sharing class IngredientUtil {

    //Variables to store Trigger.oldMap & Trigger.newMap
    List < Ingredient__c > newIngredientsList;
	Map<ID, Ingredient__c> oldIngredientsMap;
    Map<ID, Ingredient__c> newIngredientsMap; //null on insert
    

	//Constructor that takes in the map of old recipe records and new/updated recipe records and assigns them to class variables
	public IngredientUtil(List < Ingredient__c > newIngredients, Map<ID, Ingredient__c> newTriggerIngredientsMap, Map<ID, Ingredient__c> oldTriggerIngredientsMap) {
        this.newIngredientsList = newIngredients;
        this.oldIngredientsMap = oldTriggerIngredientsMap;
		this.newIngredientsMap = newTriggerIngredientsMap;
	}

    //Handler Methods called by Trigger, call functional methods in turn.
    public void onBeforeInsert() {
        checkForDupes();
    }

    public void onAfterInsert() {
        // TODO: both of these methods update Recipe__c records.  Combine into single DML, maybe with a trigger framework??
        checkForAllergins();
        flagChangesOnNonDraftRecipes();

    }

    public void onAfterUpdate() {
        checkForAllergins();
    }



    // Methods with handler logic
    public void checkForAllergins() {
        // if the ingredient is a potential allergin, mark the recipe as containing allergins
        List < ID > recipesWithAllergens = new List < ID >();

        // look for any known allergins, and grab their recipe id for updating
        for (Ingredient__c ing:this.newIngredientsList) {
            if (HelperFunctions.ingredientIsKnownAllergen(ing)) {
                recipesWithAllergens.add(ing.Recipe__c);
            }
        }

        // If we found some allergins, query for those recipes only if they're not already marked
        if (recipesWithAllergens.size()>0) {
            List < Recipe__c > recipesWithAllergensButNotMarked = [SELECT ID, Contains_Allergins__c FROM Recipe__c WHERE ID in:recipesWithAllergens AND Contains_Allergins__c=false];
            for (Recipe__c rec:recipesWithAllergensButNotMarked) {
                rec.Contains_Allergins__c = true;
            }

            update recipesWithAllergensButNotMarked;
        }
    }

    private void checkForDupes() {
        // Don't allow an ingredient to be inserted if there is already an ingredient in the system with the same name
        
        //list to hold the names of all ingredients being inserted
        List < String > ingredientNames = new List < String >();
        List < ID > recipeIds = new List < ID >();

        for (Ingredient__c i:this.newIngredientsList) {
            ingredientNames.add(i.Name);
            recipeIds.add(i.Recipe__c);
        }

        // query for any ingredients already in the database with that name
        List < Ingredient__c > existingIngredients = [SELECT ID, Name, Recipe__c FROM Ingredient__c WHERE Name in:ingredientNames AND Recipe__c in:recipeIds];

        // Now loop through the ingredients being inserted again and throw an error if there is a dupe (same ingredient on SAME recipe)
        for (Ingredient__c i:this.newIngredientsList) {
            for (Ingredient__c existingI: existingIngredients) {
                if (i.Name==existingI.Name && i.Recipe__c==existingI.Recipe__c) {
                    i.addError('There is already an ingredient with that name for this recipe!');
                }
            }
        }
    }

    //Update parent as needs review if the recipe is not in draft mode and ingredients are being added, removed or substantially changed
    private void flagChangesOnNonDraftRecipes () {
        System.debug('flagChangesOnNonDraftRecipes');

        // get a list of the non-review recipes, if any, with ingredients being added
        List < ID > recipeIds = new List < ID >();

        for (Ingredient__c i:this.newIngredientsList) {
            recipeIds.add(i.Recipe__c);
        }

        //Query for parent recipes that are not drafts status and assign to a map for easy access
        Map  < ID, Recipe__c > nonDraftRecipes = new Map < ID, Recipe__c >([SELECT ID, Draft__c FROM Recipe__c WHERE ID in:recipeIds AND Draft__c!=true]);
        
        //List to hold Recipes that need updating
        List < Recipe__c > recipesToUpdate = new List < Recipe__c >();
        // Map < ID, Account > accountMap = new Map < ID, Account >([SELECT ID, Name, AnnualRevenue FROM Account WHERE AnnualRevenue > 1000000]);
        for (Ingredient__c i:this.newIngredientsList ) {
            Recipe__c parentRecipe = nonDraftRecipes.get(i.Recipe__c); //If the recipe was not in the query, because it was not a draft, this will be null
            if (parentRecipe!=null) {
                parentRecipe.Needs_Review__c = true;
                recipesToUpdate.add(parentRecipe);
            }
        }

        // Lastly update the recipes
        update recipesToUpdate;
    }






}
