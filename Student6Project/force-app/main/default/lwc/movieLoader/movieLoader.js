import { LightningElement, api } from 'lwc';
import uploadMovieData from '@salesforce/apex/MovieDataUploadController.uploadMovieData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MovieLoader extends LightningElement {
    @api recordId;

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const fileId = uploadedFiles[0].documentId;

        uploadMovieData({ contentDocumentId: fileId })
            .then(result => {
                this.showToast('Success', `${result} records successfully loaded.`, 'success');
            })
            .catch(error => {
                this.showToast('Error', `Error during upload: ${error.body.message}`, 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}
