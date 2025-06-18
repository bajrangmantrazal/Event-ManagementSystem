public class VolunteerDeletionOnEventTriggerHandler {
    Boolean isExecuting;
    Integer size;
    Map<Id, Volunteer__c> oldMap;
    List<Volunteer__c> oldList;

    public VolunteerDeletionOnEventTriggerHandler(
        Boolean isExecuting,
        Integer size,
        Map<Id, Volunteer__c> oldMap,
        List<Volunteer__c> oldList
    ) {
        this.isExecuting = isExecuting;
        this.size = size;
        this.oldMap = oldMap;
        this.oldList = oldList;
    }

    public void beforeDelete() {
        if (oldMap == null || oldMap.isEmpty()) return;

        Set<Id> volunteerIds = oldMap.keySet();
        Set<Id> volunteersWithActiveEvents = new Set<Id>();

        List<Volunteer_Event__c> activeParticipations = [
            SELECT Volunteer__c
            FROM Volunteer_Event__c
            WHERE Volunteer__c IN :volunteerIds
            AND Event__r.Status__c NOT IN ('Completed', 'Cancelled')
        ];

        for (Volunteer_Event__c ve : activeParticipations) {
            volunteersWithActiveEvents.add(ve.Volunteer__c);
        }

        for (Volunteer__c vol : oldList) {
            if (volunteersWithActiveEvents.contains(vol.Id)) {
                vol.addError('Cannot delete volunteer with active event participation.');
            }
        }
    }
}