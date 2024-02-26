public with sharing class IngredientTriggerHandler {

    //Class Variables to store trigger context variables
    private String operationType; //Stores the Trigger.operationType in String format (e.g. BEFORE_INSERT, AFTER_INSERT etc.)
    private List < Ingredient__c > newIngredientsList; //A list of Ingredient SObjects being inserted or, in their most up-to-date state
    private Map < ID, Ingredient__c > newIngredientsMap;  //Same as the newIngredientsList but in map format
    private List < Ingredient__c > oldIngredientsList; //A list of Ingredient SObjects being updated or deleted, in whatever state they were in BEFORE the update
	private Map < ID, Ingredient__c > oldIngredientsMap; //Same as the oldIngredientsList but in map format  

    //Constructor that takes in the trigger context variables and assigns them to class variables
    public IngredientTriggerHandler(String opType, List < Ingredient__c > ingList, Map < ID, Ingredient__c > ingMap, List < Ingredient__c > ingOldList, Map < ID, Ingredient__c > ingOldMap) {
        this.operationType = opType;
        this.newIngredientsList = ingList;
        this.newIngredientsMap = ingMap;
        this.oldIngredientsList = ingOldList;
        this.oldIngredientsMap = ingOldMap;
    }

    public void processRecords() {
        if (operationType=='BEFORE_INSERT') {
            checkForDupes();
        } else if (operationType=='AFTER_INSERT') {
            // TODO: both of these methods update Recipe__c records.  Combine into single DML, maybe with a trigger framework??
            checkForAllergins();
            flagChangesOnNonDraftRecipes();
        } else if (operationType=='AFTER_UPDATE') {
            checkForAllergins();
        }
    }

    // Methods with handler logic
    private void checkForAllergins() {
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
        // Don't allow an ingredient to be added to a recipe if that same ingredient is already on that recipe
        
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
            // Check that there is a parent recipe and that the recipe isn't already in the list to update
            if (parentRecipe!=null && recipesToUpdate.contains(parentRecipe)!=true) {
                parentRecipe.Needs_Review__c = true;
                recipesToUpdate.add(parentRecipe);
            }
        }

        // Lastly update the recipes
        update recipesToUpdate;
    }
}
