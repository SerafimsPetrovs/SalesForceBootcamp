public class ReviewAnalytics {

    public static Decimal calculateBudgetRatingCorrelation() {
        List<Movie__c> movies = [SELECT Id, Budget__c, Rating_Calculated__c FROM Movie__c WHERE Budget__c != null AND Rating_Calculated__c != null];
        
        if (movies.isEmpty()) return null;

        Decimal avgBudget = 0;
        Decimal avgRating = 0;
        for (Movie__c movie : movies) {
            avgBudget += movie.Budget__c;
            avgRating += movie.Rating_Calculated__c;
        }
        avgBudget /= movies.size();
        avgRating /= movies.size();

        Decimal numerator = 0;
        Decimal denominatorBudget = 0;
        Decimal denominatorRating = 0;

        for (Movie__c movie : movies) {
            Decimal budgetDiff = movie.Budget__c - avgBudget;
            Decimal ratingDiff = movie.Rating_Calculated__c - avgRating;
            numerator += budgetDiff * ratingDiff;
            denominatorBudget += budgetDiff * budgetDiff;
            denominatorRating += ratingDiff * ratingDiff;
        }

        Decimal denominator = Math.sqrt(denominatorBudget) * Math.sqrt(denominatorRating);

        if (denominator == 0) return 0;

        return (numerator / denominator).setScale(4, RoundingMode.HALF_UP);
    }

    public static Map<String, Map<Integer, Integer>> getRatingDistribution() {
        List<Client_Review__c> reviews = [SELECT MovieLookUp__r.Title__c, Rating__c FROM Client_Review__c];

        Map<String, Map<Integer, Integer>> movieRatingDistribution = new Map<String, Map<Integer, Integer>>();

        for (Client_Review__c review : reviews) {
            String movieName = review.MovieLookUp__r.Title__c;
            Integer rating = Integer.valueOf(review.Rating__c);

            if (!movieRatingDistribution.containsKey(movieName)) {
                movieRatingDistribution.put(movieName, new Map<Integer, Integer>());
            }

            Map<Integer, Integer> ratingDist = movieRatingDistribution.get(movieName);

            if (!ratingDist.containsKey(rating)) {
                ratingDist.put(rating, 0);
            }

            ratingDist.put(rating, ratingDist.get(rating) + 1);
        }

        return movieRatingDistribution;
    }

    public static Map<String, Decimal> getAverageRatingByGenre() {
        Map<String, Decimal> genreRatingSums = new Map<String, Decimal>();
        Map<String, Integer> genreCounts = new Map<String, Integer>();

        List<Client_Review__c> reviews = [SELECT MovieLookUp__r.Genre__c, Rating__c FROM Client_Review__c];

        for (Client_Review__c review : reviews) {
            if (review.MovieLookUp__r.Genre__c != null) {
                List<String> genres = review.MovieLookUp__r.Genre__c.split(';');
                for (String genre : genres) {
                    if (!genreRatingSums.containsKey(genre)) {
                        genreRatingSums.put(genre, 0);
                        genreCounts.put(genre, 0);
                    }
                    genreRatingSums.put(genre, genreRatingSums.get(genre) + Decimal.valueOf(review.Rating__c));
                    genreCounts.put(genre, genreCounts.get(genre) + 1);
                }
            }
        }

        Map<String, Decimal> averageRatingsByGenre = new Map<String, Decimal>();
        for (String genre : genreRatingSums.keySet()) {
            if (genreCounts.get(genre) > 0) {
                averageRatingsByGenre.put(genre, (genreRatingSums.get(genre) / genreCounts.get(genre)).setScale(4, RoundingMode.HALF_UP));
            }
        }

        return averageRatingsByGenre;
    }

    public static void displayExtendedAnalytics() {
        Decimal correlation = calculateBudgetRatingCorrelation();
        System.debug('Correlation between Budget and Rating: ' + String.valueOf(correlation != null ? correlation : 0));

        Map<String, Map<Integer, Integer>> ratingDistribution = getRatingDistribution();
        for (String movie : ratingDistribution.keySet()) {
            System.debug('Rating distribution for ' + movie + ': ' + ratingDistribution.get(movie));
        }

        Map<String, Decimal> averageRatingsByGenre = getAverageRatingByGenre();
        if (averageRatingsByGenre.isEmpty()) {
            System.debug('No reviews available to display analytics.');
        } else {
            for (String genre : averageRatingsByGenre.keySet()) {
                System.debug('Average rating for genre ' + genre + ': ' + averageRatingsByGenre.get(genre));
            }
        }
    }
}
