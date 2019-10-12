@isTest
private class Recipe_Test {

    //  create a test Recipe obect in memory, then call the create() method and validate that a corresponding SObject was created
     @isTest static void createRecipeSObjectTest() {
        
        // Data Setup
        Recipe newRecipe = new Recipe(30, 'Minutes', 'Test Recipe', 4);
        // Add a description, now a required field (TODO - the constructor should take description!)
        newRecipe.description = 'A test recipe';

        Test.startTest();
        newRecipe.create();
        Test.stopTest();

        //Query for the created Recipe and validate results
        List < Recipe__c > insertedRecipeList = [SELECT ID, Name__c FROM Recipe__c];
        System.assertEquals(1, insertedRecipeList.size(), 'One Recipe SObject Expected');
        System.assertEquals('Test Recipe', insertedRecipeList[0].Name__c);

    }

    /* Create a Recipe object in memory as well as a corresponding SObject, change values on the Recipe in memory 
    and Use the updateValues method to save those changes and verify results */
    @isTest static void updateRecipeValuesTest() {

        // Data Setup
        Recipe newRecipe = new Recipe(30, 'Minutes', 'Test Recipe', 4);
        newRecipe.description = 'A test recipe';
        newRecipe.create();
        
        //TODO - This is only verifying that the name was updated.  What about the other fields that updateValues changes?
        newRecipe.name = 'Changed Test Recipe Name';

        Test.startTest();
        newRecipe.updateValues();
        Test.stopTest();

        //Query for the created Recipe
        List < Recipe__c > insertedRecipeList = [SELECT ID, Name__c FROM Recipe__c];
        System.assertEquals('Changed Test Recipe Name', insertedRecipeList[0].Name__c);   

    }

    /* Validate that the Required fields are enforced*/
    @isTest static void descriptionRequiredTest() {

        // Data Setup -- Missing Description, should not be allowed to insert
        Recipe newRecipe = new Recipe(30, 'Minutes', 'Test Recipe', 4);

        Test.startTest();
        Boolean insertSuccessful = newRecipe.create();
        Test.stopTest();

        System.assertEquals(false, insertSuccessful, 'Insert should not be allowed without description');

    }

    /* Validate that a bad id throws an exception on instantiation */
    @isTest static void badIdTest() {

        try {
            Recipe myRecipeWithBadId = new Recipe('ThisIsNotAGoodId');
        } catch (Exception e) {
            System.debug('exception : '+e);
            System.assertEquals('System.QueryException', e.getTypeName());
        }

    }
}