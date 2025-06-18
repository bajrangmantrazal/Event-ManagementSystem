// public with sharing class GetEventData {
//     @AuraEnabled(cacheable=true)
//     public static List<Event__c> alleventdata() {
//         return [
//             SELECT  
//                 Id,
//                 Name,
//                 Date__c,
//                 Capacity__c,
//                 Fundraising_Goal__c,
//                 Status__c
//             FROM Event__c
// ];
// }
// }

public with sharing class GetEventData {
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getSingleEvent(Id recordId) {
        return [
            SELECT  
                Id, 
                Name,
                Date__c,
                Capacity__c,
                Fundraising_Goal__c,
                Status__c,
                Chapter__r.Name,
                Location__City__s,Location__CountryCode__s, Location__PostalCode__s, Location__Street__s,Location__StateCode__s,   
                RecordType.Name
            FROM Event__c
  WHERE Id = :recordId
            LIMIT 1
];
}
}