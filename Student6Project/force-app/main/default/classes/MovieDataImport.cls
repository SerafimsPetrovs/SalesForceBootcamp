public class MovieDataImport {
    public static void importMovies(String jsonData) {
        List<MovieDataStructures.MovieJSON> movies = 
            (List<MovieDataStructures.MovieJSON>) JSON.deserialize(jsonData, List<MovieDataStructures.MovieJSON>.class);

        Set<String> tmdbIds = new Set<String>();
        Set<String> scriptIds = new Set<String>();
        
        for (MovieDataStructures.MovieJSON movieData : movies) {
            tmdbIds.add(movieData.tmdb_id);
            if (movieData.script != null) {
                scriptIds.add(movieData.script.id);
            }
        }

        Map<String, Movie__c> existingMoviesMap = new Map<String, Movie__c>();
        for (Movie__c movie : [SELECT Id, TMDB_Id__c FROM Movie__c WHERE TMDB_Id__c IN :tmdbIds]) {
            existingMoviesMap.put(movie.TMDB_Id__c, movie);
        }

        Map<String, Script__c> existingScriptsMap = new Map<String, Script__c>();
        if (!scriptIds.isEmpty()) {
            for (Script__c script : [SELECT Id, LegacyId__c FROM Script__c WHERE LegacyId__c IN :scriptIds]) {
                existingScriptsMap.put(script.LegacyId__c, script);
            }
        }

        List<Movie__c> moviesToInsert = new List<Movie__c>();
        List<Script__c> scriptsToInsert = new List<Script__c>();
        Map<String, String> scriptMap = new Map<String, String>();
        // test
        for (MovieDataStructures.MovieJSON movieData : movies) {
            if (existingMoviesMap.containsKey(movieData.tmdb_id)) {
                System.debug('Movie with tmdb_id ' + movieData.tmdb_id + ' already exists. Skipping.');
                continue; 
            }
        
            Movie__c movieRecord = new Movie__c();
            movieRecord.LegacyId__c = movieData.id;
            movieRecord.Title__c = movieData.name;
            movieRecord.TMDB_Id__c = movieData.tmdb_id;
            movieRecord.Genre__c = movieData.genre;
            movieRecord.Rating__c = movieData.rating;
            movieRecord.Budget__c = movieData.budget;
            movieRecord.Revenue__c = movieData.revenue;
            movieRecord.Description__c = movieData.script != null ? movieData.script.description : null;
        
            if (movieData.script != null) {
                if (existingScriptsMap.containsKey(movieData.script.id)) {
                    movieRecord.Script__c = existingScriptsMap.get(movieData.script.id).Id;
                } else {
                    Script__c scriptRecord = new Script__c();
                    scriptRecord.LegacyId__c = movieData.script.id;
                    scriptRecord.Title__c = movieData.script.name;
                    scriptRecord.Description__c = movieData.script.description;
                    scriptsToInsert.add(scriptRecord);
                    scriptMap.put(movieData.script.id, null);
                }
            }
        
            moviesToInsert.add(movieRecord);
        }

        if (!moviesToInsert.isEmpty()) {
            insert moviesToInsert;
        }

        if (!scriptsToInsert.isEmpty()) {
            insert scriptsToInsert;

            for (Script__c script : scriptsToInsert) {
                scriptMap.put(script.LegacyId__c, script.Id);
            }

            List<Movie__c> moviesToUpdate = new List<Movie__c>();
            for (Movie__c movie : moviesToInsert) {
                if (movie.Script__c == null && scriptMap.containsKey(movie.LegacyId__c)) {
                    movie.Script__c = scriptMap.get(movie.LegacyId__c);
                    moviesToUpdate.add(movie);
                }
            }

            if (!moviesToUpdate.isEmpty()) {
                update moviesToUpdate;
            }
        }

        System.debug('Movies inserted successfully: ' + moviesToInsert.size());
    }
}
