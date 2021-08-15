import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import addSession from '@salesforce/apex/SessionController.addSession';
import getLocationPickListValuesIntoList from '@salesforce/apex/SessionController.getLocationPickListValuesIntoList';

export default class AddSession extends LightningElement {
    nameValue ='';
    speaker1Value ='';
    speaker2Value ='';
    locationValue ='';
    dateTimeValue ='';
    desciptionValue ='';
    

    /*fields = ["whatever","whatever","whatever"];
    displayFields = 'Name, Email, Phone';*/

    handleNameInput(event){
        this.nameValue = event.target.value;
    }

    handleLookup(event){
        if(event.target.getAttribute('id')[0] === '1'){
            this.speaker1Value = event.detail.data.record.Id;
        }
        if(event.target.getAttribute('id')[0] === '2'){
            this.speaker2Value = event.detail.data.record.Id;
        }
    }

    @track locations = [];
    @wire(getLocationPickListValuesIntoList)
    wiredLocations({ error, data }) {
        if (data) {
            let options = [];
            for (var key in data) {
                options.push({ label: data[key], value: data[key]});
            }
            this.locations = options;
        } else if (error) {
            this.locations = [];
            throw new Error('Failed to retrieve locations');
        }
    }
    handleLocationChange(event) {
        this.locationValue = event.detail.value;
    }

    handleDateTimeInput(event){
        this.dateTimeValue = event.target.value;
    }

    handleDescriptionInput(event){
        this.desciptionValue = event.target.value;
    }
    
    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('showformchange', {
            detail: false
        }));
    }
    
    speakersList = [];
    handleSave(event) {
        if(!(this.nameValue && this.locationValue && this.dateTimeValue && (this.speaker1Value || this.speaker2Value))){
            console.log('Something is missing');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning!',
                message: 'Please enter all required fields and at least one speaker.',
                variant: 'warning'
            }), );
        }
        else{
            if(this.speaker1Value)
                this.speakersList.push(this.speaker1Value);
            if(this.speaker2Value)
                this.speakersList.push(this.speaker2Value);
            window.clearTimeout(this.delayTimeout);
            this.isLoading = true;
            this.delayTimeout = setTimeout(() => {
                addSession({ 
                    sessionName : this.nameValue,
                    sessionLocation     : this.locationValue,
                    sessionDescription : this.desciptionValue,
                    sessionTime : this.dateTimeValue,
                    sessionSpeakerId : this.speakersList
                })
                .then(result => {
                    console.log('result: ' + result);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'Session was successfuly added.',
                        variant: 'success'
                    }), );
                    this.dispatchEvent(new CustomEvent('showformchange', {
                        detail: false
                    }));
                    this.dispatchEvent(new CustomEvent('sessionadded',{
                        detail: result
                    }));
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Sorry, we could not create the session: ' + error,
                        variant: 'error'
                    }), );
                })
            }, 500);
        }
    }
}