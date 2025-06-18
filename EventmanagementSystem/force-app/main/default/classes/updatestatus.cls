// public with sharing class updatestatus {
//     @AuraEnabled
   
//     public  static void updatepParticipation_Status(Id volunteerEventId, String status) {
//         Volunteer_Event__c v =[select Id, Participation_Status__c from Volunteer_Event__c WHERE Id = :volunteerEventId LIMIT 1];  
//         v.Participation_Status__c = status; 
//         update v;}
// }

public with sharing class updatestatus {
    @AuraEnabled
    public static void updatepParticipation_Status(Id volunteerEventId, String status) {
        Volunteer_Event__c v = [
            SELECT Id, Participation_Status__c 
            FROM Volunteer_Event__c 
            WHERE Id = :volunteerEventId 
            LIMIT 1
        ];
        v.Participation_Status__c = status;
        update v;
    }
      @AuraEnabled(cacheable=true)
    public static String getEventStatus(Id eventId) {
        return [
            SELECT Status__c 
            FROM Event__c 
            WHERE Id = :eventId 
            LIMIT 1
        ].Status__c;
    }
}