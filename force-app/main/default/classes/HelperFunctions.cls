// A library of generic helper functions

global without sharing class HelperFunctions {
    
        global static List<SObject> subsetSobjects (List<SObject> objectList, Integer startIndex, Integer count, Boolean precise) {
        //given a list of sObjects a starting index and a count, returns the requested subset.  
        //If precise is true and the list is not long enough to provide the full requested subset, throws an error.  If set to false, returns what is available
        //The index must be less than the count

        //validate
        if (startIndex > objectList.size()) {
            //TODO: Throw exception
        } else if (precise == TRUE && objectList.size() - count >= startIndex) {
            //TODO: Throw exception
        }

        List < SObject > returnList = new List < SObject >(); 

        //i<list.size tests that we have not yet reached the end of the list, since we can conceivabley get a list shorter than the count requested
        //i-startIndex < count tests that we have reached the end of the requested count
        for(Integer i = startIndex; i < objectList.size() && i - startIndex < count; i++){
            returnList.add(objectList.get(i));
        }

        return returnList;
    }
}
