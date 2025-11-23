public with sharing class ContactTriggerHandler {
    public List<Contact> handlerTriggerNewList;

    public ContactTriggerHandler(List<Contact> triggerNewList) {
        this.handlerTriggerNewList = triggerNewList;
    }

    public void afterInsert_sendEmail() {
        System.debug('handler method called!');
        Integer recordCount = this.handlerTriggerNewList.size();
        // Call a utility method from another class
        EmailManager.sendMail(
            'me@evelyn.fyi',
            'RAD Sample code',
            recordCount + ' contact(s) were inserted.'
        );
    }
}