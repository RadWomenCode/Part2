trigger IngredientTrigger on Ingredient__c(
    before insert,
    after insert,
    after update
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            IngredientTriggerHandler.beforeInsert(Trigger.new);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            IngredientTriggerHandler.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            IngredientTriggerHandler.afterUpdate(Trigger.old, Trigger.new);
        }
    }
}
