@isTest
private class RecipeUtilityTest {
    

    @isTest
    static void testRequiredValuesPositive() {
        // name, active time/units, description and servings should all be reqired on final recipes
        // if any of these are missing, it should be flagged as a draft.SELECT  FROM AcceptedEventRelation
        
        // create recipe without all required fields and verify it is marked as a draft
        Recipe__c rec = new Recipe__c (
            Name='TestRecipe'
        );
        Test.startTest();
        insert rec;
        Test.stopTest();

        // Query for the inserted Recipe SObject
        Recipe__c insertedRecipe = [SELECT ID, Draft__c FROM Recipe__c WHERE Name='TestRecipe' LIMIT 1];

        System.assertEquals(true, insertedRecipe.Draft__c, 'A Recipe missing required fields must be marked as Draft');
    }

    @isTest
    static void testRequiredValuesNegative() {
        //If a recipe is inserted WITH all required fields, it should not automatically be marked as draft
        Recipe__c rec = new Recipe__c (
            Name='TestRecipe',
            Active_Time__c = 1,
            Active_Time_Units__c = 'Minutes',
            Description__c = 'Test Description.',
            Servings__c = 4
        );
        Test.startTest();
        insert rec;
        Test.stopTest();

        // Query for the inserted Recipe SObject
        Recipe__c insertedRecipe = [SELECT ID, Draft__c FROM Recipe__c WHERE Name='TestRecipe' LIMIT 1];

        System.assertEquals(false, insertedRecipe.Draft__c, 'A Recipe with all required fields should NOT be marked as Draft');
    }

    @isTest
    static void testComplexityPositive() {
        List < Recipe__c > testRecipes = new List < Recipe__c >();
        // Create a Recipe that will be considered Simple
        Recipe__c rec1 = new Recipe__c (
            Name='SimpleTestRecipe',
            Active_Time__c = 1,
            Active_Time_Units__c = 'Minutes',
            Description__c = 'Test Description.',
            Servings__c = 4
        );

        // Create a Recipe that will be considered Medium
        Recipe__c rec2 = new Recipe__c (
            Name='ModerateTestRecipe',
            Active_Time__c = 1,
            Active_Time_Units__c = 'Minutes',
            Description__c = 'Test Description.',
            Servings__c = 8
        );

        testRecipes.add(rec2);

        // Create a Recipe that will be considered Medium
        Recipe__c rec3 = new Recipe__c (
            Name='DifficultTestRecipe',
            Active_Time__c = 3,
            Active_Time_Units__c = 'Hours',
            Description__c = 'Test Description.',
            Servings__c = 8
        );

        testRecipes.add(rec3);

        Test.startTest();
        Insert testRecipes;
        Test.stopTest();

        // Query for inserted Recipes
        List < Recipe__c > recipes =  [SELECT ID, Name, Complexity__c FROM Recipe__c];

        for (Recipe__c rec: recipes) {
            if (rec.Name=='SimpleTestRecipe') {
                System.assertEquals('Simple', rec.Complexity__c, 'Recipe should be marked as Simple');
            } else if (rec.Name=='ModerateTestRecipe') {
                System.assertEquals('Moderate', rec.Complexity__c, 'Recipe should be marked as Moderate');
            } else if (rec.Name=='DifficultTestRecipe') {
                System.assertEquals('Difficult', rec.Complexity__c, 'Recipe should be marked as Difficult');
            } 
        }
    }


    @isTest
    static void testReviewTaskPositive() {
        // create a recipe that meets the criteria of being non-draft and used in at least one cookbook
        // Create Cookbook
        Cookbook__c book = new Cookbook__c(Name='TestCookbook');
        insert book;

        // Create Recipe
        Recipe__c rec = new Recipe__c (
            Name='TestRecipe',
            Active_Time__c = 3,
            Active_Time_Units__c = 'Hours',
            Description__c = 'Test Description.',
            Servings__c = 8
        );
        insert rec;

        // create junction object to indicate this recipe is in this cookbook
        Recipe_Usage__c usage = new Recipe_Usage__c (
            Cookbook__c=book.Id,
            Recipe__c=rec.Id
        );
        insert usage;

        // Now update the recipe so that a review task is generated
        rec.Contains_Allergins__c = true;
        Test.startTest();
        update rec;
        Test.stopTest();

        // query for the task
        List < Task > taskList = [SELECT ID, WhatId, ActivityDate FROM Task];

        System.assertEquals(1, taskList.size(), 'There should be one task to review the cookbook.');
        System.assertEquals(book.Id, taskList[0].WhatId, 'The task should be on the Cookbook record.');
        System.assertEquals(System.today().addDays(7),taskList[0].ActivityDate, 'The task should be due in one week.');

    }       
    
    @isTest
    static void testReviewTaskPositiveNoMultiples() {
        // create a recipe that meets the criteria of being non-draft and used in at least one cookbook
        // Create Cookbook
        Cookbook__c book = new Cookbook__c(Name='TestCookbook');
        insert book;

        // Create 2 Recipes that will be in the cookbook
        List < Recipe__c > recipes = new List < Recipe__c >();
        Recipe__c rec = new Recipe__c (
            Name='TestRecipe',
            Active_Time__c = 3,
            Active_Time_Units__c = 'Hours',
            Description__c = 'Test Description.',
            Servings__c = 8
        );
        recipes.add(rec);

        Recipe__c rec2 = new Recipe__c (
            Name='TestRecipe2',
            Active_Time__c = 1,
            Active_Time_Units__c = 'Hours',
            Description__c = 'Another Test Description.',
            Servings__c = 4
        );
        recipes.add(rec2);
        insert recipes;

        // create junction objects to indicate these recipes are in this cookbook
        List < Recipe_Usage__c > usages = new List < Recipe_Usage__c >();
        Recipe_Usage__c usage = new Recipe_Usage__c (
            Cookbook__c=book.Id,
            Recipe__c=rec.Id
        );
        usages.add(usage);
        Recipe_Usage__c usage2 = new Recipe_Usage__c (
            Cookbook__c=book.Id,
            Recipe__c=rec2.Id
        );
        usages.add(usage2);
        insert usages;

        // Now update both recipes so that a review task is generated
        List < Recipe__c > updatedRecipes = new List < Recipe__c >();
        rec.Contains_Allergins__c = true;
        rec2.Contains_Allergins__c = true;
        updatedRecipes.add(rec);
        updatedRecipes.add(rec2);

        Test.startTest();
        update updatedRecipes;
        Test.stopTest();

        // query for the task
        List < Task > taskList = [SELECT ID, WhatId FROM Task];

        System.assertEquals(1, taskList.size(), 'There should only be one task to review the cookbook.');

    }  

}
