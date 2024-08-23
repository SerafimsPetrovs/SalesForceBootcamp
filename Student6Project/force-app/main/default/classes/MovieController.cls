public with sharing class MovieController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMovies(Integer limitSize, String genre, Integer offset) {
        String query = 'SELECT Id, Name, Genre__c, Rating__c, Poster_URL__c FROM Movie__c';
        String countQuery = 'SELECT COUNT(Id) FROM Movie__c';

        if (String.isNotEmpty(genre) && !'All'.equals(genre)) {
            query += ' WHERE Genre__c INCLUDES (:genre)';
            countQuery += ' WHERE Genre__c INCLUDES (:genre)';
        }

        query += ' LIMIT :limitSize OFFSET :offset';

        Integer total = (Integer)Database.query(countQuery)[0].get('expr0');
        List<Movie__c> movies = Database.query(query);

        return new Map<String, Object>{
            'movies' => movies,
            'total' => total
        };
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGenreOptions() {
        List<Schema.PicklistEntry> picklistEntries = 
            Movie__c.Genre__c.getDescribe().getPicklistValues();
        List<String> genres = new List<String>();
        for(Schema.PicklistEntry entry : picklistEntries) {
            genres.add(entry.getLabel());
        }
        return genres;
    }
}
