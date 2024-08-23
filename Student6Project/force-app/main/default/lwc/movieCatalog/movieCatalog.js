import { LightningElement, api, wire, track } from 'lwc';
import getMovies from '@salesforce/apex/MovieController.getMovies';
import getGenreOptions from '@salesforce/apex/MovieController.getGenreOptions';
import { refreshApex } from '@salesforce/apex';

export default class MovieCatalog extends LightningElement {
    @api limitSize = 10;
    @track movies = [];
    @track filteredMovies = [];
    @track genreOptions = [];
    @track error;
    @track currentPage = 1;
    @track totalPages = 1;
    selectedGenre = '';
    wiredMoviesResult;
    limitSizeOptions = [10, 20, 50];

    @wire(getGenreOptions)
    wiredGenreOptions({ error, data }) {
        if (data) {
            this.genreOptions = data;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getMovies, { limitSize: '$limitSize', genre: '$selectedGenre', offset: '$offset' })
    wiredMovies(result) {
        this.wiredMoviesResult = result;
        const { error, data } = result;
        if (data) {
            this.movies = data.movies;
            this.filteredMovies = this.applyGenreFilter(this.movies);
            this.totalPages = Math.ceil(data.total / this.limitSize);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.movies = [];
            this.filteredMovies = [];
        }
    }

    get offset() {
        return (this.currentPage - 1) * this.limitSize;
    }

    handleFilterChange(event) {
        this.selectedGenre = event.target.value;
        this.currentPage = 1;
        return refreshApex(this.wiredMoviesResult);
    }

    handleLimitSizeChange(event) {
        this.limitSize = parseInt(event.target.value, 10);
        this.currentPage = 1;
        return refreshApex(this.wiredMoviesResult);
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            return refreshApex(this.wiredMoviesResult);
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            return refreshApex(this.wiredMoviesResult);
        }
    }

    applyGenreFilter(movies) {
        if (!this.selectedGenre || this.selectedGenre === '') {
            return movies;
        }
        return movies.filter(movie => {
            const genres = movie.Genre__c ? movie.Genre__c.split(';') : [];
            return genres.includes(this.selectedGenre);
        });
    }

    get hasMovies() {
        return this.filteredMovies && this.filteredMovies.length > 0;
    }
}
