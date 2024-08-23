public class BatchApexRunner {
    public void executeBatch() {
        MovieDataSyncBatch batch = new MovieDataSyncBatch();
        Database.executeBatch(batch, 1);
    }
}