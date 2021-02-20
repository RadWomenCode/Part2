//Used to queue the updating of a list of SObjects

//Usage:
//ID jobID = System.enqueueJob(new AsynchObjectsUpdate(<SOBJECTSTOUPDATE>));

public class AsynchObjectsUpdate implements Queueable  {
		
	List < SObject > objectsToUpdate;

	//list constructor
	public AsynchObjectsUpdate(List < SObject > objects) {
		this.objectsToUpdate = objects;
	}

	//single object constructor
	public AsynchObjectsUpdate( SObject objectToUpdate) {
		this.objectsToUpdate = new List < SObject >();
		this.objectsToUpdate.add(objectToUpdate);
	}


	public void execute (QueueableContext context) {
		system.debug('objectsBeingUpdated'+ objectsToUpdate);
		update objectsToUpdate; 
	}

}
