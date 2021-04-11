public inherited sharing class RecipeHelper {

    @AuraEnabled
    public static List < Ingredient__c > generateGroceryList(Id recipeId){
        List < Ingredient__c > allIngredients = [SELECT ID, Name, Measurement__c, Measurement_Type__c, Notes__c FROM Ingredient__c WHERE Recipe__c=:recipeId];

        return allIngredients;
    }

}
