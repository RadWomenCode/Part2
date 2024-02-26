public with sharing class SOQLExercises {

    public static void childToParentRelationshipQueries () {

        // Let's query some Opportunities and bring down account information as well
        List < Opportunity > bigOppsWithAccounts = [SELECT ID, Amount, AccountId, Account.Name FROM Opportunity WHERE Amount > 1000];
        System.debug('The first big opp with account info is: '+bigOppsWithAccounts[0]);
        System.debug('The first big opp Account Name is: '+bigOppsWithAccounts[0].Account.Name);

    }
    
    public static void parentToChildrenRelationshipQueries () {

        // Let's query Accounts and look at the child contacts as well
        // Slightly different syntax and formatting here for declaring our list, remember, there are often multiple ways to declare objects and format queries
        List<Account> acctsWithContacts = [
			SELECT Name, (SELECT FirstName,LastName FROM Contacts)
            FROM Account 
            WHERE AnnualRevenue > 1000000
		];

        System.debug('Our Accounts with contacts are: '+acctsWithContacts);
        System.debug('And the Contacts on the first account are: '+acctsWithContacts[0].Contacts);

    }

    public static void funWithAggregates () {

		//1)
		//Let's create a query to count how many opportunities we have that are over $100,000 dollars
		//Since we're just getting a count, we can put the result directly into an integer variable
		Integer bigOppsCount = [SELECT COUNT() FROM Opportunity WHERE Amount > 100000];
		System.debug('We have ' + bigOppsCount + ' Opportunities over 100K');

		//2)
		//How about the average Opportunity Amount?
		//Now we need to get the results back in a list of Aggregate Results, let's see what that looks like
		List<AggregateResult> avgAmountResult = [SELECT AVG(AMOUNT)aver FROM Opportunity];
		//*You may be wondering what the "aver" signifies, right after the AVG(AMOUNT) in the line above
		//When you have a summary field you can give it a name, to make it easier to reference
		//Check out further below, when we get just the average result specifically, we ask for it by passing in the alias ('aver')

		//This will print out the full avgAmountResult which is an array (list) of results
		System.debug('The result comes back in an array of AggregateResult Objects: '+avgAmountResult);

		//to get just the average out, we need to get it from the Aggregate Results list.  We will have only one entry
		//which is why we can reference it with [0], fetching just the first entry in the array
		Object avgAmount = avgAmountResult[0].get('aver');
		System.debug('Our Average Opp Amount is: ' + avgAmount);

		//3)
		//What if we add a group by?
		List<AggregateResult> avgAmountResultGrouped = [
			SELECT Type, AVG(AMOUNT)aver 
			FROM Opportunity 
			GROUP BY Type
		];
		

		//Let's loop through those results and print them out in a readable way
		//You'll see that adding a group by, give us something like a table
		for (AggregateResult ag: avgAmountResultGrouped) {
			//To print out the whole result object:
			System.debug('ag: '+ag);
			//To dig into values, we do get calls on the aggregate result object, passing in a string for the field name
			//The 'field name' in this case, is the name we gave it in the query, since it's a field we've generated essentially on the fly
			System.debug('For Opp Type ' + ag.get('Type') + ' the average Opp Amount is: '+ ag.get('aver'));

		}

	}

	public static void workingWithSOQLResults () {

		Account a = [
			SELECT ID, Name 
			FROM Account 
			WHERE Name='Acme Consulting Co.' 
			LIMIT 1
		];

		List < Account > accountList = [
			SELECT ID, Name, AnnualRevenue 
			FROM Account 
			WHERE AnnualRevenue > 1000000
		];

		Map < ID, Account > accountMap = new Map < ID, Account >([
			SELECT ID, Name, AnnualRevenue 
			FROM Account 
			WHERE AnnualRevenue > 1000000
		]);

	}

	public static void convertingCollectionTypes () {

		//Start with a list of Accounts
		List < Account > accountList = [SELECT ID, Name, AnnualRevenue FROM Account WHERE AnnualRevenue > 1000000];

		
		//Let's convert that list to a map.  We could
		//1) Pass the list into a map constructor like so:

		Map < ID, Account > accountMap = new Map < ID, Account >(accountList);

		//or, I could instantiate an empty map and then add the whole list to it

		Map < ID, Account > anotherAccountMap = new Map < ID, Account >();
		anotherAccountMap.putAll(accountList);


		//2) You know, what I really need is a Set of Ids for those accounts.  
		//Since a Map is indexed with a set of IDs, I can probably just get it from the map
		Set < ID > accountIdSet = accountMap.keySet();


		//3) And if I needed a list of the values in this map???
		List < Account > anotherAccountList = accountMap.values();

	}


	public static void SOSL () {

		//Let's do a search accross Accounts and Contacts where we look for records that reference 'United'

		List < List < SObject > > searchList = [FIND 'united' IN ALL FIELDS RETURNING Account(Name), Contact(FirstName,LastName)];
		System.debug('searchList: '+ searchList);

		//What if we just want to seach Name fields?
		List < List < SObject > > nameSearchList = [FIND 'united' IN NAME FIELDS RETURNING Account(Name), Contact(FirstName,LastName)];
		System.debug('nameSearchList: '+ nameSearchList);
		//Take a look at the results...Why are contacts without united in their first or last name included??


		//What if we want to search for contacts with a particular email address type?
		List < List < SObject > > emailSearch = [FIND '@uog.com' IN email FIELDS RETURNING Contact(FirstName,LastName,Account.Name,Email)];
		System.debug('emailSearch: '+ emailSearch);

	}
}