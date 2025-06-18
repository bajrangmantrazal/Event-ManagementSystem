// import { LightningElement, api, track, wire } from 'lwc';
// import getvolunteers from '@salesforce/apex/volunteersonEvent.Volunteers';
// import updatestatus from '@salesforce/apex/updatestatus.updatepParticipation_Status';
// import getEventStatus from '@salesforce/apex/updatestatus.getEventStatus';

// export default class Participantvolunteer extends LightningElement {
//     @api eventId;
//     @track volunteers = [];
//     @track filteredVolunteers = [];
//     @track searchitem = '';

//     // Wire method to fetch volunteers from Apex
//     @wire(getvolunteers, { eventId: '$eventId' })
//     wiredVolunteers({ error, data }) {
//         if (data) {
//             this.volunteers = data;
//             console.log("data",data)
//             this.filteredVolunteers = [...data];
//         } else if (error) {
//             console.error('Error fetching volunteers:', error);
//         }
//     }
//      @wire(getvolunteers, { eventId: '$eventId' })
//     wiredVolunteers({ error, data }) {
//         if (data) {
//             this.volunteers = data;
//             console.log("data",data)
//             this.filteredVolunteers = [...data];
//         } else if (error) {
//             console.error('Error fetching volunteers:', error);
//         }
//     }

//     // Handle search input
//     handleSearch(event) {
//         this.searchitem = event.target.value.toLowerCase();
//         this.filteredVolunteers = this.volunteers.filter(v =>
//             (v.Volunteer__r?.Name && v.Volunteer__r.Name.toLowerCase().includes(this.searchitem)) ||
//             (v.Participation_Status__c && v.Participation_Status__c.toLowerCase().includes(this.searchitem))
//         );
//     }

//     // Handle change in combobox status
//     handleStatusChange(event) {
//         const volunteereventId = event.target.dataset.id;
//         const newStatus = event.detail.value;

//         updatestatus({ volunteerEventId: volunteereventId, status: newStatus })
//             .then(() => {
//                 // Update local data
//                 this.volunteers = this.volunteers.map(v => {
//                     if (v.Id === volunteereventId) {
//                         return { ...v, Participation_Status__c: newStatus };
//                     }
//                     return v;
//                 });

//                 // Reapply filtering if search is active
//                 if (this.searchitem) {
//                     this.handleSearch({ target: { value: this.searchitem } });
//                 } else {
//                     this.filteredVolunteers = [...this.volunteers];
//                 }
//             })
//             .catch(error => {
//                 console.error('Error updating status:', error);
//             });
//     }

//     // Determines if volunteer table should be shown
//     get showVolunteersTable() {
//         return this.filteredVolunteers && this.filteredVolunteers.length > 0;
//     }

//     // Determines if no volunteers exist
//     get noVolunteers() {
//         return this.volunteers.length === 0;
//     }

//     // Options for the status combobox
//     statusOptions = [
//         { label: 'Registered', value: 'Registered' },
//         { label: 'Attended', value: 'Attended' },
//         { label: 'Cancelled', value: 'Cancelled' }
//     ];
// }

import { LightningElement, api, track, wire } from 'lwc';
import getvolunteers from '@salesforce/apex/volunteersonEvent.Volunteers';
import updatestatus from '@salesforce/apex/updatestatus.updatepParticipation_Status';
import getEventStatus from '@salesforce/apex/updatestatus.getEventStatus';

export default class Participantvolunteer extends LightningElement {
    @api eventId;
    @track volunteers = [];
    @track filteredVolunteers = [];
    @track searchitem = '';
    @track eventStatus;

    // Fetch volunteers
    @wire(getvolunteers, { eventId: '$eventId' })
    wiredVolunteers({ error, data }) {
        if (data) {
            this.volunteers = data;
            this.filteredVolunteers = [...data];
        } else {
            console.error('Error fetching volunteers:', error);
        }
    }

    // Fetch event status
    @wire(getEventStatus, { eventId: '$eventId' })
    wiredEventStatus({ error, data }) {
        if (data) {
            this.eventStatus = data;
        } else {
            console.error('Error fetching event status:', error);
        }
    }

    get isStatusEditable() {
        if (this.eventStatus === 'Completed' || this.eventStatus === 'Cancelled') {
            return true
        }
        return false
    }

    handleSearch(event) {
        this.searchitem = event.target.value.toLowerCase();
        this.filteredVolunteers = this.volunteers.filter(v =>
            (v.Volunteer__r?.Name && v.Volunteer__r.Name.toLowerCase().includes(this.searchitem)) ||
            (v.Participation_Status__c && v.Participation_Status__c.toLowerCase().includes(this.searchitem))
        );
    }

    handleStatusChange(event) {
        const volunteereventId = event.target.dataset.id;
        const newStatus = event.detail.value;

        updatestatus({ volunteerEventId: volunteereventId, status: newStatus })
            .then(() => {
                this.volunteers = this.volunteers.map(v => {
                    if (v.Id === volunteereventId) {
                        return { ...v, Participation_Status__c: newStatus };
                    }
                    return v;
                });

                if (this.searchitem) {
                    this.handleSearch({ target: { value: this.searchitem } });
                } else {
                    this.filteredVolunteers = [...this.volunteers];
                }
            })
            .catch(error => {
                console.error('Error updating status:', error);
            });
    }
  

    get showVolunteersTable() {
        return this.filteredVolunteers.length > 0;
    }

    get noVolunteers() {
        return this.volunteers.length === 0;
    }

    statusOptions = [
        { label: 'Registered', value: 'Registered' },
        { label: 'Attended', value: 'Attended' },
        { label: 'Cancelled', value: 'Cancelled' }
    ];
}