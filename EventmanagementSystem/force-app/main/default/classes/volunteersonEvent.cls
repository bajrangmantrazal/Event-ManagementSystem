public with sharing class volunteersonEvent {
    @AuraEnabled(cacheable=true)
    public static List<Volunteer_Event__c> Volunteers(Id eventId) {
        return [            
          SELECT
                Id,
                Event__r.Name,
                Volunteer__r.Name,
                Volunteer__r.RecordType.Name,
                Hours_Contributed__c,
                Participation_Status__c
            FROM Volunteer_Event__c
            WHERE Event__c = :eventId
];
}
}