import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getReviewsByMovie from '@salesforce/apex/ReviewController.getReviewsByMovie';
import addReview from '@salesforce/apex/ReviewController.addReview';

export default class MovieReviewForum extends LightningElement {
    @api recordId;
    @track reviews = [];
    @track newReviewText = '';
    @track newReviewRating = '';
    @track newReviewName = '';

    get ratingOptions() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
            { label: '6', value: '6' },
            { label: '7', value: '7' },
            { label: '8', value: '8' },
            { label: '9', value: '9' },
            { label: '10', value: '10' },
        ];
    }

    connectedCallback() {
        this.loadReviews();
        this.checkForToastMessage();
    }

    async loadReviews() {
        getReviewsByMovie({ movieId: this.recordId })
            .then(result => {
                this.reviews = result;
            })
            .catch(error => {
                console.error('Error loading reviews: ', error);
            });
    }

    handleReviewTextChange(event) {
        this.newReviewText = event.target.value;
    }

    handleReviewRatingChange(event) {
        this.newReviewRating = event.target.value;
    }
    handleReviewNameChange(event) {
        this.newReviewName = event.target.value;
    }
    handleSubmitReview() {
        const review = {
            Review_Text__c: this.newReviewText,
            Rating__c: this.newReviewRating,
            MovieLookUp__c: this.recordId,
            Client_Name__c: this.newReviewName,
            Review_Date__c: new Date().toISOString().split('T')[0]
        };
        addReview({ review })
            .then(() => {
                console.debug('review added');
                localStorage.setItem('reviewAdded', 'true');
                this.loadReviews();
                this.showSuccessToast();
            })
            .catch(error => {
                
                console.error('Error submitting review: ', error);
            });
    }

    checkForToastMessage() {
        if (localStorage.getItem('reviewAdded') === 'true') {
            localStorage.removeItem('reviewAdded');
            this.showSuccessToast();
        }
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Review Added',
            message: 'Your review has been successfully added.',
            variant: 'success',
        });
        this.dispatchEvent(event);
    }
}
