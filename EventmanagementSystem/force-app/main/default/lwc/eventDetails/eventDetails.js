import { api, LightningElement, wire } from 'lwc';
import getSingleEvent from '@salesforce/apex/GetEventData.getSingleEvent';

export default class EventDetails extends LightningElement {
    @api recordId;
    eventData = {};
    error;
    @wire(getSingleEvent, { recordId: '$recordId' })
    wiredEvent({ error, data }) {
        console.log("recordId", this.recordId);
        console.log("data", data);

        if (data && data.length > 0) {
            const e = data[0];

            // Date logic
            const today = new Date();
            const eventDate = e.Date__c ? new Date(e.Date__c) : null;
            let eventIn3Days = false;

            if (eventDate) {
                const diffTime = eventDate.getTime() - today.getTime();
                const diffDays = diffTime / (1000 * 60 * 60 * 24);
                eventIn3Days = diffDays >= 0 && diffDays <= 3;
            }

            this.eventData = {
                name: e.Name || '',
                date: e.Date__c || '',
                status: e.Status__c || '',
                capacity: e.Capacity__c || '',
                city: e.Location__City__s || '',
                postalCode: e.Location__PostalCode__s || '',
                street: e.Location__Street__s || '',
                country: e.Location__CountryCode__s || '',
                chapter: (e.Chapter__r && e.Chapter__r.Name) || '',
                recordType: (e.RecordType && e.RecordType.Name) || '',
                eventIn3Days: eventIn3Days
            };

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.eventData = {};
            console.error('Error loading event:', error);
        }
    }
    handleGenerateReport() {
        const eventId = this.recordId;
        if (eventId) {
            const url = `/apex/eventSummaryPdf?id=${eventId}`;
            window.open(url, '_blank');
        } else {
            alert('Event ID missing.');
        }
    }

}