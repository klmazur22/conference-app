import { LightningElement, wire, track, api } from 'lwc';
import getSessions from '@salesforce/apex/SessionController.getSessions';
export default class SessionList extends LightningElement {
    sessions = [];
    searchKey = '';
    @track showForm = false;
    @wire(getSessions, { searchKey: '$searchKey' })
    wiredSessions({ error, data }) {
        if (data) {
            this.sessions = data;
        } else if (error) {
            this.sessions = [];
            throw new Error('Failed to retrieve sessions');
        }
    }

    handleSearchKeyInput(event) {
        clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, 300);
    }

    handleSessionClick(event) {
        const { sessionId } = event.currentTarget.dataset;
        const navigateEvent = new CustomEvent('navigate', {
          detail: {
            state: 'details',
            sessionId: sessionId
          }
        });
        this.dispatchEvent(navigateEvent);
    }

    handleAddSession(event) {
        this.showForm = true;
    }

    handleShowFormChange(event) {
        this.showForm = event.detail;
    }

    handleSessionAdded(event) {
        window.open('/', '_self');
    }
}