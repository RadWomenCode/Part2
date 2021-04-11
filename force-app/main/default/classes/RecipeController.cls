public inherited sharing class RecipeController {
        
    @AuraEnabled
    public static List < Ingredient__c > generateGroceryList(Id recipeId){
	//load the ingredients and return them
            return null;
    }

    @AuraEnabled
    public static void addIngredient(String ingredientName, Integer measurementAmount, String measurementType, ID recipeId){
	//Insert the ingredient

    }

    @AuraEnabled
    public static List < Ingredient__c > scaleRecipeForServings (ID recipeId, Decimal desiredServings) {
	//Scale the recipe and return the list of scaled ingredients
        return null;
    }
                                
    @AuraEnabled(Cacheable=true)
    public static Recipe__c[] getAllRecipes() {
        return [
            SELECT
                Id,
                Name,
                Draft__c,
                Active_Time__c,
                Active_Time_Units__c,
                Complexity__c,
                Needs_Review__c,
                Possible_Duplicate__c,
                Season__c
            FROM Recipe__c
            ORDER BY Name
            LIMIT 50
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static Recipe__c[] searchRecipes(String searchTerm) {
        // Return all recipes when no search term
        searchTerm = searchTerm.trim();
        if (searchTerm == '') {
            System.debug('returning: '+getAllRecipes());
            return getAllRecipes();
        }
        // Prepare query paramters
        searchTerm = '%' + searchTerm + '%';
        // Execute search query
        return [
            SELECT
                Id,
                Name,
                Draft__c,
                Active_Time__c,
                Active_Time_Units__c,
                Complexity__c,
                Needs_Review__c,
                Possible_Duplicate__c,
                Season__c
            FROM Recipe__c
            WHERE Name LIKE :searchTerm
            ORDER BY Name
            LIMIT 50
        ];
    }
}
