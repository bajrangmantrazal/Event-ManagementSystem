import { LightningElement, track } from 'lwc';

export default class ParentComponent extends LightningElement {
    @track selectedEventId;

    handleEventSelected(event) {
        this.selectedEventId = event.detail;
    }
}