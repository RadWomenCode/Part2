global without sharing class Job_ScheduledNutritionUpdate implements Schedulable {
    // Usage for nightly run at 12:05 AM
    //Job_ScheduledNutritionUpdate snu = new Job_ScheduledNutritionUpdate();
    //string sch = '0 05 0 * 1-12 ? *';
    //system.schedule('Job_ScheduledNutritionUpdate',sch, snu);

    global void execute(SchedulableContext sc) {
        System.debug('Ok, the Job_ScheduledNutritionUpdate is running!!!!');

        // Start asynchrounous Process
    }
}
