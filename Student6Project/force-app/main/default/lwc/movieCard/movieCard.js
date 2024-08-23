import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

const FIELDS = [
    'Movie__c.Name',
    'Movie__c.Genre__c',
    'Movie__c.Rating__c',
    'Movie__c.Poster_URL__c'
];

export default class MovieCard extends NavigationMixin(LightningElement) {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    movie;

    get movieTitle() {
        return getFieldValue(this.movie.data, 'Movie__c.Name');
    }

    get movieGenre() {
        return getFieldValue(this.movie.data, 'Movie__c.Genre__c');
    }

    get movieRating() {
        return getFieldValue(this.movie.data, 'Movie__c.Rating__c');
    }

    get moviePoster() {
        return getFieldValue(this.movie.data, 'Movie__c.Poster_URL__c');
    }

    get genreList() {
        return this.movieGenre 
            ? this.movieGenre.split(';').map(genre => genre.trim().replace(/_/g, ' ').replace(/:/g, ' '))
            : [];
    }

    get genreDisplay() {
        return this.genreList.join(', ');
    }

    get isHorror() {
        return this.genreList.some(genre => genre.toLowerCase() === 'horror');
    }

    get displayRating() {
        return this.movieRating || 'N/A';
    }

    handleDetailsClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Movie__c',
                actionName: 'view',
            },
        });
    }
}