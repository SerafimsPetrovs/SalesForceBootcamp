public with sharing class ReviewController {
    @AuraEnabled(cacheable=false)
    public static List<Client_Review__c> getReviewsByMovie(Id movieId) {
        return [SELECT Id, Client_Name__c, Review_Date__c, Review_Text__c, Rating__c FROM Client_Review__c WHERE MovieLookUp__c = :movieId ORDER BY Review_Date__c DESC];
    }

    @AuraEnabled
    public static void addReview(Client_Review__c review) {
        insert review;
    }
}
