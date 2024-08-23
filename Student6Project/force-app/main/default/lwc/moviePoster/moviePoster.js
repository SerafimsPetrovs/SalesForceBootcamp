import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const FIELDS = [
    'Movie__c.Poster_URL__c'
];

export default class MoviePoster extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    movie;

    get posterUrl() {
        const url = getFieldValue(this.movie.data, 'Movie__c.Poster_URL__c');
        return url && !url.includes('null') ? url : null;
    }

    get hasPoster() {
        return this.posterUrl !== null;
    }

    get altText() {
        return `Poster for Movie ${this.recordId}`;
    }
}
