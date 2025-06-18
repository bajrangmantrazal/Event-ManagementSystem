public with sharing class EventReportController {
    public Event__c event { get; set; }
    public List<Volunteer_Event__c> volunteerEvents { get; set; }
    public Integer totalVolunteers { get; set; }
    public Decimal totalHours { get; set; }

    public EventReportController() {
        Id eventId =  ApexPages.currentPage().getParameters().get('id');

        try {
            // Fetch Event
            event = [
                SELECT Id, 
                Name,
                Date__c,
                Capacity__c,
                Fundraising_Goal__c,
                Status__c,
                Chapter__r.Name,
                Location__City__s,Location__CountryCode__s, Location__PostalCode__s, Location__Street__s,Location__StateCode__s,   
                RecordType.Name 
                FROM Event__c 
                WHERE Id = :eventId 
                LIMIT 1
            ];

            // Fetch Volunteers for the Event
            volunteerEvents = [
                SELECT Volunteer__r.Name, Volunteer__r.Email__c, Volunteer__r.Phone__c, Hours_Contributed__c
                FROM Volunteer_Event__c
                WHERE Event__c = :eventId
            ];

            // Calculate totals
            totalVolunteers = volunteerEvents.size();
            totalHours = 0;
            for (Volunteer_Event__c ve : volunteerEvents) {
                if (ve.Hours_Contributed__c != null) {
                    totalHours += ve.Hours_Contributed__c;
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error loading data: ' + e.getMessage()));
        }
    }
}