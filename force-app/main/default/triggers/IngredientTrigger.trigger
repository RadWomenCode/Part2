trigger IngredientTrigger on Ingredient__c (before insert, after insert, after update) {

    IngredientUtil iUtil = new IngredientUtil(String.valueOf(Trigger.operationType), Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    iUtil.processRecords();

}