import { LightningElement, api, track, wire } from 'lwc';
import getvolunteers from '@salesforce/apex/volunteersonEvent.Volunteers';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getUserProfileName from '@salesforce/apex/UserInfoController.getUserProfileName';


export default class EventVolunteersComponent extends LightningElement {
    @api recordId;
    @api eventStatus;

    @track volunteers = [];
    @track filteredVolunteers = [];
    @track draftValues = [];
    @track sortedBy = 'volunteerName';
    @track sortedDirection = 'asc';
    @track userProfileName;
    wiredVolunteersResult;

    columns;

    connectedCallback() {
        this.setColumns();
    }
    @wire(getUserProfileName)
    wiredUserProfile({ error, data }) {
        if (data) {
            this.userProfileName = data;
            this.setColumns(); // Recalculate columns based on profile
        } else {
            console.error('Error fetching user profile:', error);
        }
    }
    setColumns() {
        this.columns = [
            { label: 'Name', fieldName: 'volunteerName', sortable: true },
            { label: 'Hours', fieldName: 'Hours_Contributed__c', type: 'number', sortable: true },
            { label: 'Role', fieldName: 'volunteerRole', sortable: true },
            {
                label: 'Status',
                fieldName: 'Participation_Status__c',
                type: 'text',
                editable: this.isStatusEditable,
                sortable: true
            }
        ];
    }

    get isStatusEditable() {
        console.log("eventStatus", this.eventStatus);
        console.log("this.userProfileName", this.userProfileName)
        const isAdmin = this.userProfileName === 'System Administrator';
        const isFinalStatus = this.eventStatus === 'Completed' || this.eventStatus === 'Cancelled';
        // return !(isAdmin || isFinalStatus);
         return !(isFinalStatus);
    }

    @wire(getvolunteers, { eventId: '$recordId' })
    wiredVolunteers(result) {
        this.wiredVolunteersResult = result;
        const { data, error } = result;
        if (data) {
            this.volunteers = data.map(v => ({
                ...v,
                volunteerName: v.Volunteer__r?.Name,
                volunteerRole: v.Volunteer__r?.RecordType?.Name
            }));
            this.filteredVolunteers = [...this.volunteers];
        } else if (error) {
            console.error('Error fetching volunteers:', error);
        }
    }

    get showVolunteersTable() {
        return this.filteredVolunteers.length > 0;
    }

    get noVolunteers() {
        return this.volunteers.length === 0;
    }

    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        this.filteredVolunteers = this.volunteers.filter(v =>
            (v.volunteerName && v.volunteerName.toLowerCase().includes(searchTerm)) ||
            (v.Participation_Status__c && v.Participation_Status__c.toLowerCase().includes(searchTerm))
        );
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredVolunteers];
        cloneData.sort((a, b) => {
            const valA = a[sortedBy] || '';
            const valB = b[sortedBy] || '';
            return sortDirection === 'asc'
                ? valA.localeCompare(valB)
                : valB.localeCompare(valA);
        });
        this.filteredVolunteers = cloneData;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
    }

    handleSave(event) {
        this.draftValues = event.detail.draftValues;

        const recordInputs = this.draftValues.map(draft => {
            const fields = { ...draft };
            return { fields };
        });

        const updatePromises = recordInputs.map(recordInput => updateRecord(recordInput));

        Promise.all(updatePromises)
            .then(() => {
                this.draftValues = [];
                return refreshApex(this.wiredVolunteersResult);
            })
            .catch(error => {
                console.error('Error updating records:', error);
            });
    }
}




// import { LightningElement, api, track, wire } from 'lwc';
// import getvolunteers from '@salesforce/apex/volunteersonEvent.Volunteers';
// import { updateRecord } from 'lightning/uiRecordApi';
// import { refreshApex } from '@salesforce/apex';
// import getUserProfileName from '@salesforce/apex/UserInfoController.getUserProfileName';


// export default class EventVolunteersComponent extends LightningElement {
//     @api recordId;
//     @api eventStatus;

//     @track volunteers = [];
//     @track filteredVolunteers = [];
//     @track draftValues = [];
//     @track sortedBy = 'volunteerName';
//     @track sortedDirection = 'asc';
//     @track userProfileName;
//     wiredVolunteersResult;

//     columns;

//     connectedCallback() {
//         this.setColumns();
//     }
//     @wire(getUserProfileName)
//     wiredUserProfile({ error, data }) {
//         if (data) {
//             this.userProfileName = data;
//             this.setColumns(); // Recalculate columns based on profile
//         } else {
//             console.error('Error fetching user profile:', error);
//         }
//     }
//     options =[
//         { label: 'Active', value: 'Active' },
//         { label: 'Inactive', value: 'Inactive' }
//     ]
//     setColumns() {
//         this.columns = [
//             { label: 'Name', fieldName: 'volunteerName', sortable: true },
//             { label: 'Hours', fieldName: 'Hours_Contributed__c', type: 'number', sortable: true },
//             { label: 'Role', fieldName: 'volunteerRole', sortable: true },
//             {
//                 label: 'Status',
//                 fieldName: 'Participation_Status__c',
//                 options: this.options,
//                placeholder:"Select Please",
//                 editable: this.isStatusEditable,
//                 sortable: true,
//                 context:{fieldName},
//                 contextName:"Id"
//             }
//         ];
//     }

//     get isStatusEditable() {
//         console.log("eventStatus", this.eventStatus);
//         console.log("this.userProfileName", this.userProfileName)
//         const isAdmin = this.userProfileName === 'System Administrator';
//         const isFinalStatus = this.eventStatus === 'Completed' || this.eventStatus === 'Cancelled';
//         return !(isAdmin || isFinalStatus);
//     }

//     @wire(getvolunteers, { eventId: '$recordId' })
//     wiredVolunteers(result) {
//         this.wiredVolunteersResult = result;
//         const { data, error } = result;
//         if (data) {
//             this.volunteers = data.map(v => ({
//                 ...v,
//                 volunteerName: v.Volunteer__r?.Name,
//                 volunteerRole: v.Volunteer__r?.RecordType?.Name
//             }));
//             this.filteredVolunteers = [...this.volunteers];
//         } else if (error) {
//             console.error('Error fetching volunteers:', error);
//         }
//     }

//     get showVolunteersTable() {
//         return this.filteredVolunteers.length > 0;
//     }

//     get noVolunteers() {
//         return this.volunteers.length === 0;
//     }

//     handleSearch(event) {
//         const searchTerm = event.target.value.toLowerCase();
//         this.filteredVolunteers = this.volunteers.filter(v =>
//             (v.volunteerName && v.volunteerName.toLowerCase().includes(searchTerm)) ||
//             (v.Participation_Status__c && v.Participation_Status__c.toLowerCase().includes(searchTerm))
//         );
//     }

//     handleSort(event) {
//         const { fieldName: sortedBy, sortDirection } = event.detail;
//         const cloneData = [...this.filteredVolunteers];
//         cloneData.sort((a, b) => {
//             const valA = a[sortedBy] || '';
//             const valB = b[sortedBy] || '';
//             return sortDirection === 'asc'
//                 ? valA.localeCompare(valB)
//                 : valB.localeCompare(valA);
//         });
//         this.filteredVolunteers = cloneData;
//         this.sortedBy = sortedBy;
//         this.sortedDirection = sortDirection;
//     }

//     handleSave(event) {
//         this.draftValues = event.detail.draftValues;

//         const recordInputs = this.draftValues.map(draft => {
//             const fields = { ...draft };
//             return { fields };
//         });

//         const updatePromises = recordInputs.map(recordInput => updateRecord(recordInput));

//         Promise.all(updatePromises)
//             .then(() => {
//                 this.draftValues = [];
//                 return refreshApex(this.wiredVolunteersResult);
//             })
//             .catch(error => {
//                 console.error('Error updating records:', error);
//             });
//     }
// }