public class fetchMovieData {
    @future(callout=true)
    public static void fetchMovieDataAsync(List<String> tmdbIds, List<Id> movieRecordIds) {
        try {
            if (tmdbIds == null || movieRecordIds == null || tmdbIds.size() != movieRecordIds.size()) {
                throw new IllegalArgumentException('TMDB IDs and Movie Record IDs lists must be non-null and of equal length.');
            }

            Map<String, tmdb.tmdbMovieResponse> tmdbIdToMovieDataMap = new Map<String, tmdb.tmdbMovieResponse>();
            tmdb tmdbService = new tmdb();

            for (String tmdbId : tmdbIds) {
                tmdb.tmdbMovieResponse movieData = tmdbService.getMovieById(tmdbId);
                if (movieData != null) {
                    tmdbIdToMovieDataMap.put(tmdbId, movieData);
                }
            }

            List<Movie__c> movieRecordsToUpdate = new List<Movie__c>();
            for (Integer i = 0; i < tmdbIds.size(); i++) {
                String tmdbId = tmdbIds[i];
                Id recordId = movieRecordIds[i];
                tmdb.tmdbMovieResponse movieData = tmdbIdToMovieDataMap.get(tmdbId);

                if (movieData != null) {
                    Movie__c movieRecord = new Movie__c(Id = recordId);
                    movieRecord.Description__c = movieData.overview;
                    movieRecord.Title__c = movieData.original_title;
                    movieRecord.Poster_URL__c = 'https://image.tmdb.org/t/p/w600_and_h900_bestv2' + movieData.poster_path;
                    movieRecord.Budget__c = movieData.budget;
                    movieRecord.Rating__c = movieData.vote_average;
                    movieRecord.Revenue__c = movieData.revenue;
                    movieRecord.TMDBSyncDate__c = Date.today();
                    movieRecordsToUpdate.add(movieRecord);
                } else {
                    System.debug('No movie data found for TMDB ID: ' + tmdbId);
                }
            }

            if (!movieRecordsToUpdate.isEmpty()) {
                update movieRecordsToUpdate;
                System.debug('Movie records updated successfully: ' + movieRecordsToUpdate);
            }
        } catch (Exception e) {
            System.debug('Error in fetchMovieDataAsync: ' + e.getMessage());
        }
    }
}
