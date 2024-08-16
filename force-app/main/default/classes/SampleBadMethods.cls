public with sharing class SampleBadMethods {
    public class SampleCustomException extends Exception {
    }

    //This method throws a custom exception, because we have a specific data requirement (positive integers)
    //Without the custom check and exception, this code would run, but not meet our specs
    public static Integer iAddUpPositiveIntegers(Integer intA, Integer intB) {
        //First validate that we have positive integers only
        if (intA < 0 || intB < 0) {
            throw new SampleCustomException('I only take positive integers!');
        } else {
            return intA + intB;
        }
    }

    //This method will throw a built-in exception because it is attempting to access a value that doesn't exist
    public static void thisIsNotGoingToGoWell() {
        List<Account> aList = [
            SELECT ID, Name
            FROM Account
            WHERE Name = 'Acme'
        ];

        //however many accounts we have with the name "Acme" there sure aren't 51 of them, hence, this will throw an exception
        Account notHere = aList[50];
    }
}
