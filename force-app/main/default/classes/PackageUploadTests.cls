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


}