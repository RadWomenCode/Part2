public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private Map<Id, Opportunity> newOppMap;

    public OpportunityTriggerHandler() {
        System.debug('contructing');
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        // This trigger processes Before and After updates/inserts, so the expected loop count is 2 (1 for before, and one for after)
        this.setMaxLoopCount(2);
    }

    public override void afterUpdate() {
        System.debug('in after opp update');
        // Some afterUpdate logic that we only want to run once
    }
  
  
  
}