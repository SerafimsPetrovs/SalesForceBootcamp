import { LightningElement, api, wire } from 'lwc';
import getGenreOptions from '@salesforce/apex/MovieController.getGenreOptions';

export default class MovieCatalogFilter extends LightningElement {
    @api filterLabel;
    genreOptions = [];
    selectedGenre = '';

    @wire(getGenreOptions)
    wiredGenres({ error, data }) {
        if (data) {
            this.genreOptions = [{ label: 'All', value: '' }, ...data.map(genre => ({ label: genre, value: genre }))];
        } else if (error) {
            this.genreOptions = [];
            console.error('Error fetching genre options:', error);
        }
    }

    handleGenreChange(event) {
        this.selectedGenre = event.target.value;
        const filterChangeEvent = new CustomEvent('filterchange', {
            detail: { selectedGenre: this.selectedGenre }
        });
        this.dispatchEvent(filterChangeEvent);
    }
}
