public with sharing class MovieDataUploadController {

    @AuraEnabled
    public static Integer uploadMovieData(String contentDocumentId) {
        ContentVersion contentVersion = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
        String jsonContent = contentVersion.VersionData.toString();

        Set<String> existingTmdbIds = new Set<String>();
        for (Movie__c existingMovie : [SELECT TMDB_Id__c FROM Movie__c WHERE TMDB_Id__c != null]) {
            existingTmdbIds.add(existingMovie.TMDB_Id__c);
        }
        List<Movie__c> moviesToInsert = new List<Movie__c>();
        List<Object> movieDataList = (List<Object>) JSON.deserializeUntyped(jsonContent);
        for (Object movieDataObj : movieDataList) {
            Map<String, Object> movieData = (Map<String, Object>) movieDataObj;
            String tmdbId = String.valueOf(movieData.get('tmdb_id'));

            if (existingTmdbIds.contains(tmdbId)) {
                continue;
            }
            Movie__c movie = new Movie__c();
            movie.Title__c = (String) movieData.get('name');
            movie.Budget__c = (movieData.get('budget') != null) ? Decimal.valueOf(String.valueOf(movieData.get('budget'))) : null;
            movie.Revenue__c = (movieData.get('revenue') != null) ? Decimal.valueOf(String.valueOf(movieData.get('revenue'))) : null;
            movie.Genre__c = (String) movieData.get('genre');
            movie.Rating__c = (movieData.get('rating') != null) ? Decimal.valueOf(String.valueOf(movieData.get('rating'))) : null;
            movie.TMDB_Id__c = tmdbId;
            movie.TMDBSyncDate__c = Date.today();
            movie.Description__c = (String) movieData.get('overview');
            
            moviesToInsert.add(movie);
        }

        if (!moviesToInsert.isEmpty()) {
            insert moviesToInsert;
        }
        
        return moviesToInsert.size();
    }
}
