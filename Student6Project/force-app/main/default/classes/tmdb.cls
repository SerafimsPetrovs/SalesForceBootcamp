public with sharing class tmdb {
    private static final String API_KEY = '5bfef77f0d03fea766a8ab7ddfe11ab1';
    private static final String API_KEY_PARAM_NAME = 'api_key';
    private static final String API_VERSION = '3';
    private static final String BASE_URL = 'https://api.themoviedb.org/';

    public String authQueryParameter {
        get {
            return API_KEY_PARAM_NAME + '=' + API_KEY;
        }
    }

    public String buildResourceUrl(String resourceName) {
        return BASE_URL + API_VERSION + resourceName;
    }

    public HttpRequest authenticateRequest(HttpRequest request) {
        String endpoint = request.getEndpoint();
        if (endpoint.contains('?')) {
            endpoint += '&' + authQueryParameter;
        } else {
            endpoint += '?' + authQueryParameter;
        }
        request.setEndpoint(endpoint);
        return request;
    }

    public tmdbMovieResponse getMovieById(String movieId) {
        String resourceName = '/movie/' + movieId + '?language=en-US';
        String endpoint = buildResourceUrl(resourceName);
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request = authenticateRequest(request);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('Response Body: ' + response.getBody());
        tmdbMovieResponse movieData = (tmdbMovieResponse) JSON.deserialize(response.getBody(), tmdbMovieResponse.class);
        return movieData;
    }

    public void saveMovieDataToSalesforce(String movieId, Id recordId) {
        tmdbMovieResponse movieData = getMovieById(movieId);
        Movie__c movieRecord = [SELECT Id, Genre__c FROM Movie__c WHERE Id = :recordId LIMIT 1];
        List<String> genres = new List<String>();
        for (tmdbGenre genre : movieData.genres) {
            genres.add(genre.name);
            System.debug('Genre received: ' + genre.name);
        }
        
        movieRecord.Genre__c = String.join(genres, ', ');
        movieRecord.Title__c = movieData.original_title;
        movieRecord.Description__c = movieData.overview;
        movieRecord.Rating__c = movieData.vote_average;
        movieRecord.Budget__c = movieData.budget;
        movieRecord.Revenue__c = movieData.revenue;
        movieRecord.TMDBSyncDate__c = Date.today();
        
        update movieRecord;
    }

    public class tmdbMovieResponse {
        public String overview;
        public String original_title;
        public Long revenue;
        public Double vote_average;
        public String poster_path;
        public Integer budget;
        public List<tmdbGenre> genres;
    }

    public class tmdbGenre {
        public Integer id;
        public String name;
    }
}
