//Used to queue the updating of a list of SObjects

//Usage:
//ID jobID = System.enqueueJob(new QueueableObjectUpdater(<SOBJECTSTOUPDATE>));

public class QueueableObjectUpdater implements Queueable {
    public List<SObject> objectsToUpdate;
    public List<SObject> objectsToQueueForUpdate;

    //single object constructor
    public QueueableObjectUpdater(SObject objectToUpdate) {
        this.objectsToUpdate = new List<SObject>();
        this.objectsToUpdate.add(objectToUpdate);
    }

    //list constructor
    public QueueableObjectUpdater(List<SObject> objects) {
        Integer dmlRowLimit = Limits.getLimitDmlRows();

        if (this.objectsToUpdate.size() <= dmlRowLimit) {
            //We are under the limit, no need to queue up another job, everything goes in the update list
            this.objectsToUpdate = objects;
        } else {
            // We are trying to update more records than we have in our limits. Do up to the limit, then queue the remainder for the next job
            // each job will whittle the list down until we're done!

            // we will use a helper method to divide our big list into the first batch and future batch
            this.objectsToUpdate = HelperFunctions.subsetSobjects(
                objects,
                0,
                dmlRowLimit,
                false
            );
            this.objectsToQueueForUpdate = HelperFunctions.subsetSobjects(
                objects,
                dmlRowLimit,
                objects.size() - dmlRowLimit,
                false
            );
        }
    }

    public void execute(QueueableContext context) {
        system.debug('objectsBeingUpdatedCount' + objectsToUpdate.size());
        update objectsToUpdate;

        // If we have objects to queue up for updating in the next batch, do so now
        if (
            this.objectsToQueueForUpdate != null &&
            this.objectsToQueueForUpdate.size() > 0
        ) {
            ID jobID = System.enqueueJob(
                new QueueableObjectUpdater(this.objectsToQueueForUpdate)
            );
        }
    }
}
