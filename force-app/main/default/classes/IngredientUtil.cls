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

    //Handler Methods
    public void onBeforeInsert() {

        // Don't allow an ingredient to be inserted if there is already an ingredient in the system with the same name
        
        //list to hold the names of all ingredients being inserted
        List < String > ingredientNames = new List < String >();
        List < ID > recipeIds = new List < ID >();

        for (Ingredient__c i:newIngredientsList) {
            ingredientNames.add(i.Name);
            recipeIds.add(i.Recipe__c);
        }

        // query for any ingredients already in the database with that name
        List < Ingredient__c > existingIngredients = [SELECT ID, Name, Recipe__c FROM Ingredient__c WHERE Name in:ingredientNames AND Recipe__c in:recipeIds];

        // Now loop through the ingredients being inserted again and throw an error if there is a dupe
        for (Ingredient__c i:newIngredientsList) {
            for (Ingredient__c existingI: existingIngredients) {
                if (i.Name==existingI.Name && i.Recipe__c==existingI.Recipe__c) {
                    i.addError('There is already an ingredient with that name for this recipe!');
                }
            }
        }
    }

    public void onAfterInsert() {
        checkForAllergins();
    }

    public void onAfterUpdate() {
        checkForAllergins();
    }

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






}