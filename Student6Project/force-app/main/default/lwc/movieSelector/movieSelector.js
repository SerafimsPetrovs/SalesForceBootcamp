import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import searchMovie from '@salesforce/apex/TMDBIntegration.searchMovie';
import TITLE_FIELD from '@salesforce/schema/Movie__c.Title__c';
import TMDB_ID_FIELD from '@salesforce/schema/Movie__c.TMDB_Id__c';
import GENRE_FIELD from '@salesforce/schema/Movie__c.Genre__c';
import RATING_FIELD from '@salesforce/schema/Movie__c.Rating__c';

const FIELDS = [TITLE_FIELD];

export default class MovieSelector extends LightningElement {
    @api recordId;
    @track movies = [];
    @track error;
    @track isLoading = false;
    movieTitle = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredMovie({ error, data }) {
        if (data) {
            this.movieTitle = data.fields.Title__c.value;
            if (this.movieTitle) {
                this.handleSearchMovie();
            }
        } else if (error) {
            this.error = error;
        }
    }

    handleSearchMovie() {
        if (!this.movieTitle) {
            return;
        }

        this.isLoading = true;
        searchMovie({ title: this.movieTitle })
            .then(result => {
                this.movies = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
    }

    handleSelectMovie(event) {
        const selectedMovieId = event.target.dataset.id;
        const selectedMovie = this.movies.find(movie => movie.id === selectedMovieId);

        if (selectedMovie) {
            const fields = {
                [TMDB_ID_FIELD.fieldApiName]: selectedMovie.id,
                [TITLE_FIELD.fieldApiName]: selectedMovie.title,
                [GENRE_FIELD.fieldApiName]: selectedMovie.genre,
                [RATING_FIELD.fieldApiName]: selectedMovie.vote_average
            };
            const recordInput = { fields: { ...fields, Id: this.recordId } };

            updateRecord(recordInput)
                .then(() => {
                    console.log('Movie data copied successfully!');
                    location.reload();
                })
                .catch(error => {
                    console.error('Error copying movie data:', error);
                });
        }
    }
}
