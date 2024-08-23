public with sharing class TMDBIntegration {
    private static final String API_KEY = '5bfef77f0d03fea766a8ab7ddfe11ab1';

    @AuraEnabled(cacheable=true)
    public static List<MovieDTO> searchMovie(String title) {
        String endpoint = 'https://api.themoviedb.org/3/search/movie?query=' + EncodingUtil.urlEncode(title, 'UTF-8') + '&api_key=' + API_KEY;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            List<Object> movies = (List<Object>)results.get('results');
            List<MovieDTO> movieList = new List<MovieDTO>();

            for (Object movieObj : movies) {
                Map<String, Object> movieMap = (Map<String, Object>)movieObj;
                MovieDTO movieDTO = new MovieDTO();
                movieDTO.id = String.valueOf(movieMap.get('id'));
                movieDTO.title = (String)movieMap.get('title');
                movieDTO.vote_average = (Double)movieMap.get('vote_average');
                movieDTO.overview = (String)movieMap.get('overview');
                movieList.add(movieDTO);
            }
            return movieList;
        } else {
            throw new AuraHandledException('Failed to fetch movies from TMDB');
        }
    }

    @AuraEnabled
    public static void copyMovieData(Id movieId, MovieDTO selectedMovie) {
        Movie__c movieRecord = [SELECT Id, TMDB_Id__c FROM Movie__c WHERE Id = :movieId LIMIT 1];
        if (movieRecord != null && selectedMovie != null) {
            movieRecord.TMDB_Id__c = selectedMovie.id;
            movieRecord.Title__c = selectedMovie.title;
            movieRecord.Rating__c = selectedMovie.vote_average;
            movieRecord.Description__c = selectedMovie.overview;
            movieRecord.TMDBSyncDate__c = Date.today();
            update movieRecord;
        }
    }
    
    public class MovieDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public Double vote_average;
        @AuraEnabled public String overview;
    }
}
