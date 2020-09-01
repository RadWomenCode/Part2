public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private Map<Id, Opportunity> newOppMap;

    // Intitializing and setting defaults
    public OpportunityTriggerHandler() {
        System.debug('contructing');
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        // This trigger processes Before and After updates/inserts, so the expected loop count is 2 (1 for before, and one for after)
        this.setMaxLoopCount(2);
    }

    // ACTUAL TRIGGER PROCESSING STARTS HERE
    public override void beforeUpdate() {
        System.debug('in before opp update');
        // Update needs attention based on closed status and date (yes, could be done declaratively---Demo purposes)
        Date today = System.today();
        for (Opportunity opp: this.newOppMap.values()) {
            if (!opp.isClosed && opp.CloseDate<=today) {
                opp.Needs_Attention__c = true;
            }
        }
    }

    public override void afterUpdate() {
        System.debug('in after opp update');
        // Some afterUpdate logic that we only want to run once
    }
  
  
  
}
