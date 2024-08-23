trigger MovieTrigger on Movie__c (after insert, after update) {
    List<String> tmdbIds = new List<String>();
    List<Id> movieRecordIds = new List<Id>();
    Integer batchSize = 50;

    for (Movie__c movie : Trigger.new) {
        if (movie.tmdb_id__c != null && 
            (Trigger.isInsert || 
            (Trigger.isUpdate && movie.tmdb_id__c != Trigger.oldMap.get(movie.Id).tmdb_id__c))) {
            
            tmdbIds.add(movie.tmdb_id__c);
            movieRecordIds.add(movie.Id);
        }
    }

    if (!tmdbIds.isEmpty() && !movieRecordIds.isEmpty()) {
        System.enqueueJob(new FetchMovieDataQueueable(tmdbIds, movieRecordIds, 0, batchSize));
    }
}
