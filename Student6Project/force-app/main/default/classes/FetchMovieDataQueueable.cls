public class FetchMovieDataQueueable implements Queueable, Database.AllowsCallouts {
    private List<String> tmdbIds;
    private List<Id> movieRecordIds;
    private Integer startIndex;
    private Integer batchSize;

    public FetchMovieDataQueueable(List<String> tmdbIds, List<Id> movieRecordIds, Integer startIndex, Integer batchSize) {
        this.tmdbIds = tmdbIds;
        this.movieRecordIds = movieRecordIds;
        this.startIndex = startIndex;
        this.batchSize = batchSize;
    }

    public void execute(QueueableContext context) {
        Integer endIndex = Math.min(startIndex + batchSize, tmdbIds.size());

        List<String> currentBatchTmdbIds = new List<String>();
        List<Id> currentBatchMovieRecordIds = new List<Id>();

        for (Integer i = startIndex; i < endIndex; i++) {
            currentBatchTmdbIds.add(tmdbIds[i]);
            currentBatchMovieRecordIds.add(movieRecordIds[i]);
        }

        List<Movie__c> movieRecordsToUpdate = new List<Movie__c>();
        tmdb tmdbService = new tmdb();

        for (Integer i = 0; i < currentBatchTmdbIds.size(); i++) {
            tmdb.tmdbMovieResponse movieData = tmdbService.getMovieById(currentBatchTmdbIds[i]);
            if (movieData != null) {
                Movie__c movieRecord = new Movie__c(Id = currentBatchMovieRecordIds[i]);
                movieRecord.Description__c = movieData.overview;
                movieRecord.Title__c = movieData.original_title;
                movieRecord.Poster_URL__c ='https://image.tmdb.org/t/p/w600_and_h900_bestv2' + movieData.poster_path;
                movieRecord.Budget__c = movieData.budget;
                movieRecord.Rating__c = movieData.vote_average;
                movieRecord.Revenue__c = movieData.revenue;
                movieRecord.TMDBSyncDate__c = Date.today();
                movieRecordsToUpdate.add(movieRecord);
            }
        }

        if (!movieRecordsToUpdate.isEmpty()) {
            update movieRecordsToUpdate;
        }

        if (endIndex < tmdbIds.size()) {
            FetchMovieDataQueueable nextBatch = new FetchMovieDataQueueable(tmdbIds, movieRecordIds, endIndex, batchSize);
            System.enqueueJob(nextBatch);
        }
    }
}
