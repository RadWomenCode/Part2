public with sharing class IngredientTriggerHandler {
    public static void beforeInsert(List<Ingredient__c> newList) {
        checkForDupes(newList);
    }

    public static void afterInsert(List<Ingredient__c> newList) {
        checkForAllergens(newList);
        flagChangesOnNonDraftRecipes(newList);
    }

    public static void afterUpdate(
        List<Ingredient__c> oldList,
        List<Ingredient__c> newList
    ) {
        checkForAllergens(newList);
    }

    // Methods with handler logic
    private static void checkForAllergens(List<Ingredient__c> ingredientsList) {
        // if the ingredient is a potential allergen, mark the recipe as containing allergens
        List<ID> recipesWithAllergens = new List<ID>();

        // look for any known allergens, and grab their recipe id for updating
        for (Ingredient__c ing : ingredientsList) {
            if (HelperFunctions.ingredientIsKnownAllergen(ing)) {
                recipesWithAllergens.add(ing.Recipe__c);
            }
        }

        // If we found some allergens, query for those recipes only if they're not already marked
        if (recipesWithAllergens.size() > 0) {
            List<Recipe__c> recipesWithAllergensButNotMarked = [
                SELECT ID, Contains_Allergens__c
                FROM Recipe__c
                WHERE
                    ID IN :recipesWithAllergens
                    AND Contains_Allergens__c = FALSE
            ];
            for (Recipe__c rec : recipesWithAllergensButNotMarked) {
                rec.Contains_Allergens__c = true;
            }

            update recipesWithAllergensButNotMarked;
        }
    }

    private static void checkForDupes(List<Ingredient__c> ingredientsList) {
        // Don't allow an ingredient to be added to a recipe if that same ingredient is already on that recipe

        // list to hold the names of all ingredients being inserted
        List<String> ingredientNames = new List<String>();
        List<ID> recipeIds = new List<ID>();

        for (Ingredient__c i : ingredientsList) {
            ingredientNames.add(i.Name);
            recipeIds.add(i.Recipe__c);
        }

        // query for any ingredients already in the database with that name
        List<Ingredient__c> existingIngredients = [
            SELECT ID, Name, Recipe__c
            FROM Ingredient__c
            WHERE Name IN :ingredientNames AND Recipe__c IN :recipeIds
        ];

        // Now loop through the ingredients being inserted again and throw an error if there is a dupe (same ingredient on SAME recipe)
        for (Ingredient__c i : ingredientsList) {
            for (Ingredient__c existingI : existingIngredients) {
                if (
                    i.Name == existingI.Name &&
                    i.Recipe__c == existingI.Recipe__c
                ) {
                    i.addError(
                        'There is already an ingredient with that name for this recipe!'
                    );
                }
            }
        }
    }

    // Update parent as needs review if the recipe is not in draft mode and ingredients are being added, removed or substantially changed
    private static void flagChangesOnNonDraftRecipes(
        List<Ingredient__c> ingredientsList
    ) {
        // get a list of the non-review recipes, if any, with ingredients being added
        List<ID> recipeIds = new List<ID>();

        for (Ingredient__c i : ingredientsList) {
            recipeIds.add(i.Recipe__c);
        }

        // Query for parent recipes that are not drafts status and assign to a map for easy access
        Map<ID, Recipe__c> nonDraftRecipes = new Map<ID, Recipe__c>(
            [
                SELECT ID, Draft__c
                FROM Recipe__c
                WHERE ID IN :recipeIds AND Draft__c != TRUE
            ]
        );

        // List to hold Recipes that need updating
        List<Recipe__c> recipesToUpdate = new List<Recipe__c>();
        // Map < ID, Account > accountMap = new Map < ID, Account >([SELECT ID, Name, AnnualRevenue FROM Account WHERE AnnualRevenue > 1000000]);
        for (Ingredient__c i : ingredientsList) {
            Recipe__c parentRecipe = nonDraftRecipes.get(i.Recipe__c); // If the recipe was not in the query, because it was not a draft, this will be null
            // Check that there is a parent recipe and that the recipe isn't already in the list to update
            if (
                parentRecipe != null &&
                recipesToUpdate.contains(parentRecipe) != true
            ) {
                parentRecipe.Needs_Review__c = true;
                recipesToUpdate.add(parentRecipe);
            }
        }

        // Lastly update the recipes
        update recipesToUpdate;
    }
}
