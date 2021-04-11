public inherited sharing class RecipeController {
    
    @AuraEnabled
    public static List < Ingredient__c > generateGroceryList(Id recipeId){
        List < Ingredient__c > allIngredients = [SELECT ID, Name, Measurement__c, Measurement_Type__c, Notes__c FROM Ingredient__c WHERE Recipe__c=:recipeId];

        return allIngredients;
    }

    @AuraEnabled
    public static void addIngredient(String ingredientName, Integer measurementAmount, String measurementType, ID recipeId){

        Ingredient__c i = new Ingredient__c (
            Name = ingredientName,
            Measurement__c = measurementAmount,
            Measurement_Type__c = measurementType,
            Recipe__c = recipeId
        );

        insert i;

    }

    @AuraEnabled
    public static List < Ingredient__c > scaleRecipeForServings (ID recipeId, Decimal desiredServings) {
        Recipe__c rec = [SELECT ID, Servings__c FROM Recipe__c WHERE ID=:recipeId];

        List < Ingredient__c > allIngredients = [SELECT ID, Name, Measurement__c, Measurement_Type__c, Notes__c FROM Ingredient__c WHERE Recipe__c=:recipeId];
        System.debug('desiredServings: '+desiredServings);
        System.debug('rec.Servings__c: '+rec.Servings__c);
        Decimal scalingMultiplier = desiredServings.divide(rec.Servings__c,1,System.RoundingMode.HALF_UP);

        for (Ingredient__c ing: allIngredients) {
            ing.Measurement__c = Integer.valueOf(ing.measurement__c * scalingMultiplier);
        }
        System.debug('allIngredients: '+allIngredients);
        return allIngredients;


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
