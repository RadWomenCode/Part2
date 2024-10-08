// A library of generic helper functions

global without sharing class HelperFunctions {
    // Given a recipe, returns an Integer indicating the complexity, 1 being the simplist and 3 being the most difficult
    public static Integer rateRecipeComplexity(Recipe__c rec) {
        System.debug('rec: ' + rec);
        // If the recipe has an active time of an hour or more, it's difficult
        if (
            (rec.Active_Time_Units__c == 'Minutes' &&
            rec.Active_Time__c >= 60) ||
            rec.Active_Time_Units__c == 'Hours' &&
            rec.Active_Time__c >= 1
        ) {
            return 3;
            // If it's less than an hour but it has over 6 servings, we'll call it moderate
        } else if (rec.Servings__c > 6) {
            return 2;
            // Otherwise, it's considered simple
        } else {
            return 1;
        }
    }

    public static Boolean ingredientIsKnownAllergen(Ingredient__c ing) {
        System.debug('ing name: ' + ing.Name);
        // This method is stubbed; in a more realistic scenario, we would be calling out to a database of known allergens
        Set<String> knownAllergens = new Set<String>{
            'Wheat',
            'Eggs',
            'Milk',
            'Peanuts',
            'Fish',
            'Shellfish',
            'Shrimp',
            'Soy'
        };
        if (knownAllergens.contains(ing.Name)) {
            return true;
        } else {
            return false;
        }
    }

    global static List<SObject> subsetSobjects(
        List<SObject> objectList,
        Integer startIndex,
        Integer count,
        Boolean precise
    ) {
        // Given a list of sObjects a starting index and a count, returns the requested subset.
        // If precise is true and the list is not long enough to provide the full requested subset, throws an error.  If set to false, returns what is available
        // The index must be less than the count

        // Validate
        if (startIndex > objectList.size()) {
            // TODO: Throw exception
        } else if (precise == true && objectList.size() - count >= startIndex) {
            // TODO: Throw exception
        }

        List<SObject> returnList = new List<SObject>();

        // i < list.size tests that we have not yet reached the end of the list, since we can conceivabley get a list shorter than the count requested
        // i-startIndex < count tests that we have reached the end of the requested count
        for (
            Integer i = startIndex;
            i < objectList.size() &&
            i - startIndex < count;
            i++
        ) {
            returnList.add(objectList.get(i));
        }

        return returnList;
    }
}
