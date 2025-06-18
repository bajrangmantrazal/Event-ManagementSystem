public class VolunteerLimitationOnEventTriggerHandler {
    Boolean isExecuting;
    Integer size;
    List<Volunteer_Event__c> newList;

    public VolunteerLimitationOnEventTriggerHandler(
        Boolean isExecuting,
        Integer size,
        List<Volunteer_Event__c> newList
    ) {
        this.isExecuting = isExecuting;
        this.size = size;
        this.newList = newList;
    }

    public void beforeInsert() {
        Set<Id> volunteerIds = new Set<Id>();

        // Step 1: Collect Volunteer IDs
        for (Volunteer_Event__c ve : newList) {
            if (ve.Volunteer__c != null) {
                volunteerIds.add(ve.Volunteer__c);
            }
        }

        // Step 2: Query existing active Volunteer_Event__c records
        Map<Id, Integer> volunteerEventCount = new Map<Id, Integer>();

        if (!volunteerIds.isEmpty()) {
            List<Volunteer_Event__c> existingEvents = [
                SELECT Volunteer__c, Event__r.Status__c
                FROM Volunteer_Event__c
                WHERE Volunteer__c IN :volunteerIds
                AND Event__r.Status__c NOT IN ('Completed', 'Cancelled')
            ];

            for (Volunteer_Event__c ve : existingEvents) {
                Id volunteerId = ve.Volunteer__c;
                Integer count = volunteerEventCount.get(volunteerId);
                volunteerEventCount.put(volunteerId, count == null ? 1 : count + 1);
            }
        }

        // Step 3: Enforce limit of 5 active events per volunteer
        for (Volunteer_Event__c ve : newList) {
            if (ve.Volunteer__c != null) {
                Integer currentCount = volunteerEventCount.containsKey(ve.Volunteer__c)
                    ? volunteerEventCount.get(ve.Volunteer__c)
                    : 0;

                if (currentCount >= 5) {
                    ve.addError('Volunteer cannot be assigned to more than 5 active events.');
                } else {
                    volunteerEventCount.put(ve.Volunteer__c, currentCount + 1);
                }
            }
        }
    }
}