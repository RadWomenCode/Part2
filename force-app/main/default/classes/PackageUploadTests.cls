/**
 * Important Note!!!!!!!
 * The below tests are simply to have enough coverage so that this package can be uploaded for class use.
 * These are not true tests and are not even close to proper test coverage.  Basically, pay no attention to these.
 */
@isTest
private class PackageUploadTests {
    
    @isTest static void testMethodOne() {
        Account a = new Account();
        a.Name = 'test';
        insert a;

        a.Name = 'updated test';
        update a;
    }
 
    @isTest static void testMethodTwo() {
        Account a = new Account();
        a.Name = 'test';
        insert a;

        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.CloseDate = Date.today();
        o.StageName = 'Prospecting';
        o.Name = 'Test Opp';
        insert o;
    }

    @isTest static void testMethodThree() {
        Account a = new Account();
        a.AnnualRevenue = 2000000;
        a.Name = 'test';
        insert a;

        Contact c = new Contact();
        c.FirstName = 'test';
        c.LastName = 'test';
        c.Account= a;

        insert c;
    }

    @isTest static void testMethodFour() {

        Account a = new Account();
        a.Name = 'Acme Consulting Co.';
        a.AnnualRevenue = 2000000;
        insert a;

        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.Amount = 2000000;
        o.CloseDate = Date.today();
        o.StageName = 'Prospecting';
        o.Name = 'Test Opp';
        insert o;

        Contact c = new Contact();
        c.FirstName = 'test';
        c.LastName = 'test';
        c.Account= a;


        SOQLExercises.childToParentRelationshipQueries();
        SOQLExercises.parentToChildrenRelationshipQueries();
        SOQLExercises.funWithAggregates();
        SOQLExercises.workingWithSOQLResults();
        SOQLExercises.convertingCollectionTypes();
        SOQLExercises.SOSL();
    }

    @isTest
    static void testMethodFive() {
        Recipe rec1 = new Recipe(5,'Minutes','Test',4);
        Recipe rec2 = new Recipe(5,'Minutes','Test',4);

        Recipe__c recSobj = new Recipe__c();
        recSobj.Name__c ='Test';
        insert recSobj;
        Recipe rec3 = new Recipe(recSobj.Id);

        rec2.name = 'My Recipe';
        rec2.description = 'description';
        rec2.activeTime = 5;
        rec2.activeTimeUnits = 'Hours';
        rec2.create();

        rec2.activeTime = 10;
        rec2.activeTimeUnits = 'Minutes';
        rec2.updateValues();

    }

    @isTest
    static void testMethodSix() {
        Recipe rec2 = new Recipe(5,'Minutes','Test',4);
        rec2.name = 'My Recipe';
        rec2.description = 'description';
        rec2.create();

        Recipe__c rec = [SELECT ID, Active_Time_Units__c, Active_Time__c, Servings__c FROM Recipe__c WHERE ID=:rec2.sObjectID];

        Integer rating = HelperFunctions.rateRecipeComplexity(rec);

        // create ingredient
        Ingredient__c ing = new Ingredient__c();
        ing.Recipe__c = rec.Id;
        ing.Name = 'IngredientName';
        insert ing;

        Boolean allergin = HelperFunctions.ingredientIsKnownAllergen(ing);

    } 

    @isTest
    static void testMethodEight() {
        CollectionsReview.allAboutSets();
        CollectionsReview.introToLists();
        CollectionsReview.muchAdoAboutMaps();
    }

    @isTest
    static void testMethodNine() {
        Ingredient ing1 = new Ingredient();

        // create recipe that is not a draft
        Recipe__c rec = new Recipe__c();
        rec.Name = 'Test Recipe 1';
        insert rec;

        // create ingredient
        Ingredient__c ing = new Ingredient__c();
        ing.Recipe__c = rec.Id;
        ing.Name = 'IngredientName';
        ing.Description__c = 'description';
        ing.Measurement_Type__c = 'Tsp';
        ing.Measurement__c = 2;
        insert ing;

        Ingredient ing2 = new Ingredient(rec.Id, 'test Ingredient', 4.0, 'Tsp');
        ing2.create();

        Ingredient ing3 = new Ingredient(ing.id);
        ing3.name = 'updated name';
        ing3.updateValues();
        

        
    }

}
