global class MovieDataImportBatch implements Database.Batchable<String> {
    private String jsonData;

    global MovieDataImportBatch(String jsonData) {
        this.jsonData = jsonData;
    }

    global Iterable<String> start(Database.BatchableContext BC) {
        ExecutionFlags.isBatchOrQueueableContext = true; 
        List<String> jsonChunks = splitJsonIntoChunks(jsonData);
        System.debug('Number of chunks created in start method: ' + jsonChunks.size());
        return jsonChunks;
    }

    global void execute(Database.BatchableContext BC, List<String> jsonChunks) {
        for (String jsonChunk : jsonChunks) {
            System.debug('Processing chunk: ' + jsonChunk);
            List<MovieDataStructures.MovieJSON> movies = 
                (List<MovieDataStructures.MovieJSON>) JSON.deserialize(jsonChunk, List<MovieDataStructures.MovieJSON>.class);
            System.debug('Number of movies in chunk: ' + movies.size());
            MovieDataImport.importMovies(JSON.serialize(movies));
        }
    }

    global void finish(Database.BatchableContext BC) {
        ExecutionFlags.isBatchOrQueueableContext = false;
        System.debug('Batch Apex processing finished.');
    }

    private List<String> splitJsonIntoChunks(String jsonData) {
        List<MovieDataStructures.MovieJSON> movies = 
            (List<MovieDataStructures.MovieJSON>) JSON.deserialize(jsonData, List<MovieDataStructures.MovieJSON>.class);

        List<String> jsonChunks = new List<String>();
        Integer chunkSize = 100;

        for (Integer i = 0; i < movies.size(); i += chunkSize) {
            List<MovieDataStructures.MovieJSON> chunk = new List<MovieDataStructures.MovieJSON>();

            for (Integer j = i; j < Math.min(i + chunkSize, movies.size()); j++) {
                chunk.add(movies[j]);
            }

            String serializedChunk = JSON.serialize(chunk);
            jsonChunks.add(serializedChunk);
            System.debug('Chunk created with size: ' + chunk.size() + ' | Serialized Chunk Length: ' + serializedChunk.length());
        }

        System.debug('Total chunks created: ' + jsonChunks.size());
        return jsonChunks;
    }
}
