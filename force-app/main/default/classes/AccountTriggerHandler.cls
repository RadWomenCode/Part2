public with sharing class AccountTriggerHandler {
    // -----------Trigger Recursion Control------------------------------------------------------
    static Boolean hasRunOnce = false; // Has the Account trigger already executed? -- The Handler updates this variable when first run in each context, then resets at the end. The BeforeInsert logic will run once and only once, the AfterInsert logic will run once and only once, etc.

    // -----------Trigger Handler Class Variables -----------------------------------------------
    List<Account> newAccounts;
    Map<ID, Account> oldAccountMap;

    // Constructor receives the accounts being processed by this trigger and assigns them to class variables
    public AccountTriggerHandler(
        List<Account> newAccounts,
        Map<ID, Account> oldAccountMap
    ) {
        this.newAccounts = newAccounts;
        this.oldAccountMap = oldAccountMap;
    }

    // TODO: Remove comments below and on line 127 to activate code
    /*
    public void handleBeforeInsert(){
        if(hasRunOnce) {
            return;
        }
        hasRunOnce = true;
        setPrioritiesBeforeInsert();
        hasRunOnce = false;     
    }

    public void handleAfterInsert(){
        if(hasRunOnce) {
            return;
        }
        hasRunOnce = true;
        handleNewAccountsAfterInsert();
        hasRunOnce = false;             
    }

    public void handleAfterUpdate(){
        if(hasRunOnce) {
            return;
        }
        hasRunOnce = true;
        handlePriorityChangeAfterUpdate();
        hasRunOnce = false; 
    }

    private void setPrioritiesBeforeInsert() {
        for (Account a : this.newAccounts) {
            if (a.AnnualRevenue >= 5000000) {
                a.CustomerPriority__c = 'Highest';
            } else if (a.AnnualRevenue >= 3000000) {
                a.CustomerPriority__c = 'High';
            } else if (a.AnnualRevenue >= 1000000) {
                a.CustomerPriority__c = 'Medium';
            } else {
                a.CustomerPriority__c = 'Low';
            }
        }
        // this is a before trigger, so our handler doesn't have to call DML
    }

    private void handleNewAccountsAfterInsert() {
        Id runningUserId = UserInfo.getUserId();

        // Week 3 Demo: bulkify this code
        for (Account a : this.newAccounts) {
            Case c = new Case();
            c.Status = 'New';
            c.Origin = 'New Account'; // Make sure you've added this as a picklist value for this field
            c.Subject = 'Send Welcome Package';
            c.AccountId = a.Id;
            c.Description = 'Please follow up with this new Account and send them a Welcome Package.';

            // Check for a Campaign that should be associated with the case
            // If this user has a campaign that is active of type Referral Program and this account has a source of Partner Referral, add the campaign
            // There should be only one per business rules.... but is there any potential issue you can see with the the code below???
            if (a.AccountSource=='Partner Referral') {
                List<Campaign> campaigns = [SELECT ID FROM Campaign WHERE OwnerId=:runningUserId AND IsActive=true AND Type='Referral Program'];
                c.Campaign__c = campaigns[0].ID;
            }
        
            insert c;
        }
    }

    private void handlePriorityChangeAfterUpdate() {
        // First thing we do is query for all the opportunities on accounts involved in this trigger
        // The SOQL query below uses a nested query, this let's us pull back each acccount with a list of its opportunities attached.
        // We won't be covering nested queries in this class, but take a look and see if you can figure out how they work
        Map<Id, Account> acctsWithOpps = new Map<Id, Account>(
            [SELECT Id, (SELECT Id FROM Opportunities WHERE IsClosed = false) FROM Account WHERE Id IN :this.newAccounts]
        );

        // Let's make a list to hold any opportunities we create for later insertion
        List<Opportunity> newOpportunities = new List<Opportunity>();

        // Now we need to loop through the accounts in this trigger and see if their priority has been changed in the way we're looking for
        for (Account updatedAcct : this.newAccounts) {

            // ok, so now we have the udpated Account record, but we also need to compare it to the old version to see what has changed
            // We can use the oldAccountMap, pass it the Account Id, and we'll get the old version for comparison
            Account oldAcct = this.oldAccountMap.get(updatedAcct.Id);

            // ok, now we have the new and old versions of the same record and we can make our comparison
            if ((oldAcct.CustomerPriority__c != 'Highest' && oldAcct.CustomerPriority__c != 'High') && (updatedAcct.CustomerPriority__c == 'Highest' || updatedAcct.CustomerPriority__c == 'High')) {
                // we have a winner!  now check and see if the account has any Open Opportunities

                System.debug('Number of Opportunities on this Account' + acctsWithOpps.get(updatedAcct.Id).Opportunities.size());

                if (acctsWithOpps.get(updatedAcct.Id).Opportunities.size() == 0) {
                    // Ok, this account has no open opportunities, let's create one
                    Opportunity opp = new Opportunity();
                    opp.Name = updatedAcct.Name + ' Opportunity';
                    opp.StageName = 'Prospecting';
                    opp.CloseDate = Date.today().addMonths(3);
                    opp.AccountId = updatedAcct.Id;
                    newOpportunities.add(opp);
                }
            }
        }

        // Finally, insert any new Opportunities
        if (newOpportunities.size() > 0) {
            insert newOpportunities;
        }
    }
    */
}
