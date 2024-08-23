public class MovieDataSyncScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        MovieDataSyncBatch batch = new MovieDataSyncBatch();
        Database.executeBatch(batch, 1);
    }
}