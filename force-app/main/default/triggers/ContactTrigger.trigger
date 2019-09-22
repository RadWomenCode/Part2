/*
Source Code:https://trailhead.salesforce.com/en/content/learn/modules/apex_triggers/apex_triggers_intro
*/

trigger ContactTrigger on Contact (after insert, after delete) {
    if (Trigger.isInsert) {
        Integer recordCount = Trigger.New.size();
        // Call a utility method from another class
        EmailManager.sendMail('putYourEmail@here.com', 'RAD Sample code', 
                    recordCount + ' contact(s) were inserted.');
    }
    else if (Trigger.isDelete) {
        // Process after delete
    }
}