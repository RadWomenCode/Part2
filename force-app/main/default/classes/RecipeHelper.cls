public inherited sharing class RecipeHelper {

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

}
