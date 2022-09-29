trigger AccountTrigger on Account (before insert, after insert, after update) {
    
    /***************This Trigger should only be run ONCE**********************************************/
    if (AccountTriggerHandler.hasExecuted) { //references a static variable on the handler
        return;
    } else if (Trigger.isAfter) {
        //Once we're in the after context, set the static variable to true, so that we don't re-enter
        AccountTriggerHandler.hasExecuted = true;
    }

    //*********************************************************************************************** */
    // Instantiate the Handler and set Trigger records
    AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.new, Trigger.oldMap);

    // First, we have a simple if/else if block separating inserts from updates 
    // This helps trigger performance and keeps triggers with lots of handlers more readable

    // TODO: Remove comment start/end below and on line 33 to activate code
    /*
    if (Trigger.isInsert) {
        if(Trigger.isBefore){
            handler.handleBeforeInsert();
        } else if(Trigger.isAfter){
            handler.handleAfterInsert();
        }
        
    } else if (Trigger.isUpdate){
        //we don't have any business logic for before updates, so we don't need to have an unused if statement
        if(Trigger.isAfter){
            handler.handleAfterUpdate();
        }
    }
    */

    //future trigger logic blocks here
    
}
