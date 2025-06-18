// import { api, LightningElement, track, wire } from 'lwc';
// import alleventdata from '@salesforce/apex/GetEventData.alleventdata'
// import getUserRoleOrProfile from '@salesforce/apex/UserAccessController.getUserRoleOrProfile';
// export default class Event extends LightningElement {
//     @track events = [];
//     @track searchitem = '';
//     @track filteredEvents = [];
//      @track userRole = '';
//     @track isCoordinator = false;
//     @api recordId
//     @wire(alleventdata)
//     wiredEvents({ data, error }) {
//         if (data) {
//             console.log("data",data)
//             const today = new Date();

//             this.events = data.map(e => {
//                 const eventDate = e.Date__c ? new Date(e.Date__c) : null;
//                 let eventin3days = false;
//                 if (eventDate) {
//                     const diffTime = eventDate.getTime() - today.getTime();
//                     const diffDays = diffTime / (1000 * 60 * 60 * 24);
//                     eventin3days = diffDays >= 0 && diffDays <= 3;
//                 }

//                 return {
//                     ...e,
//                     isSelected: false,
//                     statusBadgeClass: this.getStatusClass(e.Status__c),
//                     eventin3days,
//                     hasNoVolunteers: !e.Volunteer_Count_c || e.Volunteer_Count__c === 0,
//                     isEditable: !(e.Status_c === 'Completed' || e.Status__c === 'Cancelled')
//                 };
//             });
//         } else if (error) {
//             console.error('Error fetching events:', error);
//         }
//     }
//     @wire(getUserRoleOrProfile)
//     wiredUserRole({ data, error }) {
//         if (data) {
//             this.userRole = data;
//             console.log(" this.userRole", this.userRole)
//             this.isCoordinator = (data.includes('Coordinator') || data.includes('Event Lead'));
//         } else if (error) {
//             console.error('Failed to get user role', error);
//         }
//     }
//    handleGenerateReport(event) {
//     const eventId = event.currentTarget.dataset.id;
//     if (eventId) {
//       console.log("eventId",eventId)
//         const url = `/apex/eventSummaryPdf?id=${eventId}`;
//         window.open(url, '_blank');
//     } else {
//         alert('Event ID missing.');
//     }
// }


//     getStatusClass(status) {
//         switch (status) {
//             case 'Completed':
//                 return 'slds-badge slds-theme_success';
//             case 'Scheduled':
//                 return 'slds-badge slds-theme_info';
//             case 'Cancelled':
//                 return 'slds-badge slds-theme_error';
//             default:
//                 return 'slds-badge';
//         }
//     }
// }


import { api, LightningElement, track } from 'lwc';
import getSingleEvent from '@salesforce/apex/GetEventData.getSingleEvent';
import getUserRoleOrProfile from '@salesforce/apex/UserAccessController.getUserRoleOrProfile';

export default class Event extends LightningElement {
    @track events = [];
    @track userRole = '';
    @track isCoordinator = false;
    @api recordId;

    connectedCallback() {
        if (this.recordId) {
            // Single record fetch
            getSingleEvent({ recordId: this.recordId })
                .then(event => {
                    this.events = [this.processEvent(event)];
                })
                .catch(error => {
                    console.error('Error fetching single event:', error);
                });
        } else {
            // All records
            // alleventdata()
            //     .then(data => {
            //         this.events = data.map(e => this.processEvent(e));
            //     })
            //     .catch(error => {
            //         console.error('Error fetching all events:', error);
            //     });
            console.log("hell")
        }

        getUserRoleOrProfile()
            .then(data => {
                this.userRole = data;
                this.isCoordinator = data.includes('Coordinator') || data.includes('Event Lead');
            })
            .catch(error => {
                console.error('Failed to get user role', error);
            });
    }

    processEvent(e) {
        const today = new Date();
        const eventDate = e.Date__c ? new Date(e.Date__c) : null;
        let eventin3days = false;

        if (eventDate) {
            const diffTime = eventDate.getTime() - today.getTime();
            const diffDays = diffTime / (1000 * 60 * 60 * 24);
            eventin3days = diffDays >= 0 && diffDays <= 3;
        }

        return {
            ...e,
            isSelected: this.recordId ? true : false,
            statusBadgeClass: this.getStatusClass(e.Status__c),
            eventin3days,
            hasNoVolunteers: !e.Volunteer_Count__c || e.Volunteer_Count__c === 0,
            isEditable: !(e.Status__c === 'Completed' || e.Status__c === 'Cancelled')
        };
    }

    toggleDetails(event) {
        const selectedId = event.currentTarget.dataset.id;
        this.events = this.events.map(e => ({
            ...e,
            isSelected: e.Id === selectedId ? !e.isSelected : e.isSelected
        }));
    }

    handleGenerateReport(event) {
        const eventId = event.currentTarget.dataset.id;
        if (eventId) {
            const url = `/apex/eventSummaryPdf?id=${eventId}`;
            window.open(url, '_blank');
        } else {
            alert('Event ID missing.');
        }
    }

    getStatusClass(status) {
        switch (status) {
            case 'Completed':
                return 'slds-badge slds-theme_success';
            case 'Scheduled':
                return 'slds-badge slds-theme_info';
            case 'Cancelled':
                return 'slds-badge slds-theme_error';
            default:
                return 'slds-badge';
        }
    }
}