/*trigger Dublicate_Volunteer_Assignment_Trigger on Volunteer_Event__c(before insert, before update) {
List<Volunteer_Event__c>existingevent = [select event__c from Volunteer_Event__c ];
List<Volunteer_Event__c>existingvolunteer =[select Volunteer__c from Volunteer_Event__c ];
     for(Volunteer_Event__c  e:trigger.new){
         for(Volunteer_Event__c i:existingevent){
             if(e.event__c==i.event__c){
  
                 for(Volunteer_Event__c j:existingvolunteer){
  
                     if(e.Volunteer__c==j.Volunteer__c){
  
                         e.addError('Volunteer is already exist in this event!');
                         
                     }
                 }
             }
             
             
         }
         
         }
 
}
*/


trigger Dublicate_Volunteer_Assignment_Trigger on Volunteer_Event__c (before insert) {
    Set<String> existing = new Set<String>();

    for (Volunteer_Event__c rec : [
        SELECT Volunteer__c, Event__c FROM Volunteer_Event__c
        WHERE Volunteer__c != null AND Event__c != null
    ]) {
        existing.add(rec.Volunteer__c + '-' + rec.Event__c);
    }

    for (Volunteer_Event__c rec : Trigger.new) {
        if (rec.Volunteer__c != null && rec.Event__c != null) {
            String key = rec.Volunteer__c + '-' + rec.Event__c;
            if (existing.contains(key)) {
                rec.addError('Volunteer is already exist in this event!');
            }
        }
    }
}