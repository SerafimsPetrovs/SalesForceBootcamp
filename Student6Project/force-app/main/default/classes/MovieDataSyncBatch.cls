global class MovieDataSyncBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, TMDBSyncDate__c, tmdb_id__c FROM Movie__c WHERE (TMDBSyncDate__c = NULL OR TMDBSyncDate__c < LAST_N_DAYS:30) AND tmdb_id__c != NULL';
        return Database.getQueryLocator(query);
    }
 public void execute(Database.BatchableContext bc, List<Movie__c> scope) {
    tmdb tmdbService = new tmdb();

    for (Movie__c movie : scope) {
        tmdb.tmdbMovieResponse movieDetails = tmdbService.getMovieById(movie.tmdb_id__c);

        if (movieDetails != null) {
            movie.Revenue__c = movieDetails.revenue;
            movie.Rating__c = movieDetails.vote_average;
            movie.Description__c = movieDetails.overview;
            movie.Title__c = movieDetails.original_title;
            movie.Budget__c = movieDetails.budget;
            movie.TMDBSyncDate__c = Date.today();
        }
    }
    update scope;
}


    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Apex job completed successfully.');
    }
}