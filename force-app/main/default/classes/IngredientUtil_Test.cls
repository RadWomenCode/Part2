@isTest
private class IngredientUtil_Test {

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