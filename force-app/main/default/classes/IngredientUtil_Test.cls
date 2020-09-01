@isTest
private class IngredientUtil_Test {

    
    @isTest static void testFlagNonDraftRecipe () {
        // when a new ingredient is added, non-draft recipes should be flagged for review. 
        
        // create recipe that is not a draft
        Recipe__c rec = new Recipe__c();
        rec.Name = 'Test Recipe 1';
        insert rec;

        // create ingredient
        Ingredient__c ing = new Ingredient__c();
        ing.Recipe__c = rec.Id;
        ing.Name = 'IngredientName';
        insert ing;

        // validate that the recipe is now marked as needs review
        Recipe__c updatedRecipe = [SELECT ID, Needs_Review__c FROM Recipe__c WHERE ID=:rec.Id];
        
        System.assertEquals(true, updatedRecipe.Needs_Review__c);
        
    }


    @isTest static void testDupeChecker(){

        // 1. Data Setup
        // create recipe
        Recipe__c rec = new Recipe__c();
        rec.Name = 'Test Recipe 1';
        insert rec;

        // create ingredient
        Ingredient__c ing = new Ingredient__c();
        ing.Recipe__c = rec.Id;
        ing.Name = 'IngredientName';
        insert ing;

        // Attempt to create a duplicate ingredient and verify an error is shown
        Ingredient__c dupeIng = new Ingredient__c();
        dupeIng.Recipe__c = rec.Id;
        dupeIng.Name = 'IngredientName';

        // Run the Test
        Test.startTest();

        try {
            insert dupeIng;
        } catch (Exception e) {
            // Did we get the expected error?
            System.assertEquals(e.getTypeName(), 'System.DmlException');
        }

        Test.stopTest();

    }

}
