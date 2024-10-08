@IsTest
private class Recipe_Test {
    //  create a test Recipe obect in memory, then call the create() method and validate that a corresponding SObject was created
    @IsTest
    private static void createRecipeSObjectTest() {
        // Data Setup
        Recipe newRecipe = new Recipe(30, 'Minutes', 'Test Recipe', 4);
        // Add a description, now a required field (TODO - the constructor should take description!)
        newRecipe.description = 'A test recipe';

        Test.startTest();
        newRecipe.create();
        Test.stopTest();

        // Query for the created Recipe and validate results
        List<Recipe__c> insertedRecipeList = [SELECT ID, Name FROM Recipe__c];
        System.assertEquals(
            1,
            insertedRecipeList.size(),
            'One Recipe SObject Expected'
        );
        System.assertEquals('Test Recipe', insertedRecipeList[0].Name);
    }

    /* Create a Recipe object in memory as well as a corresponding SObject, change values on the Recipe in memory
     and Use the updateValues method to save those changes and verify results */
    @IsTest
    private static void updateRecipeValuesTest() {
        // Data Setup
        Recipe newRecipe = new Recipe(30, 'Minutes', 'Test Recipe', 4);
        newRecipe.description = 'A test recipe';
        newRecipe.create();

        Test.startTest();
        newRecipe.name = 'Changed Test Recipe Name';
        newRecipe.updateValues();
        Test.stopTest();

        // Query for the created Recipe
        List<Recipe__c> insertedRecipeList = [SELECT ID, Name FROM Recipe__c];
        System.assertEquals(
            'Changed Test Recipe Name',
            insertedRecipeList[0].Name
        );
    }

    /* Validate that the Required fields are enforced*/
    @IsTest
    private static void descriptionRequiredTest() {
        // Data Setup -- Missing Description, should not be allowed to insert
        Recipe newRecipe = new Recipe(30, 'Minutes', 'Test Recipe', 4);

        Test.startTest();
        Boolean insertSuccessful = newRecipe.create();
        Test.stopTest();

        System.assertEquals(
            false,
            insertSuccessful,
            'Insert should not be allowed without description'
        );
    }

    /* Validate that a bad id throws an exception on instantiation */
    @IsTest
    private static void badIdTest() {
        try {
            Recipe myRecipeWithBadId = new Recipe('ThisIsNotAGoodId');
        } catch (Exception e) {
            System.debug('exception : ' + e);
            System.assertEquals('System.QueryException', e.getTypeName());
        }
    }
}
