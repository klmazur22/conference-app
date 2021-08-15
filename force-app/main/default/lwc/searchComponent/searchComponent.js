import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import searchContact from '@salesforce/apex/SessionController.searchContact';
export default class SearchComponent extends LightningElement {

    @api labelName;
    @api currentRecordId;

    searchTerm;
    delayTimeout;

    searchRecords;
    selectedRecord;

    ICON_URL = '/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#contact';

    handleInputChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            if(searchKey.length > 1){
                searchContact({
                    searchTerm : searchKey 
                })
                .then(result => {
                    this.searchRecords = result;
                })
                .catch(error => {
                    console.error('Error:', error);
                })
            }
            else{
                this.searchRecords = undefined;
            }
        }, 300);
    }

    handleSelect(event){
        let recordId = event.currentTarget.dataset.recordId;
        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        this.dispatchEvent(new CustomEvent('lookup', {
            detail: {  
                data : {
                    record          : selectRecord,
                    recordId        : recordId,
                    currentRecordId : this.currentRecordId
                }
            }
        }));
    }

    handleClear(){
        this.selectedRecord = undefined;
        this.searchRecords  = undefined;
        this.dispatchEvent(new CustomEvent('lookup', {
            detail: {  
                record ,
                recordId,
                currentRecordId : this.currentRecordId
            }
        }));
    }
}