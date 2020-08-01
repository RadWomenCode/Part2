trigger IngredientTrigger on Ingredient__c (before insert, after insert, after update) {
    System.debug('trigger.newMap: '+trigger.newMap);
    IngredientUtil iUtil = new IngredientUtil(trigger.new, trigger.newMap, trigger.oldMap);
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            iUtil.onBeforeInsert();
        } 
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            iUtil.onAfterInsert();
        } else if (Trigger.isUpdate) {
            iUtil.onAfterUpdate();
        }
    }
}