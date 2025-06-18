@isTest
public class Test_DuplicateVolunteerAssignmentTrigger {

    @isTest static void testDuplicateAssignment() {
        Volunteer__c v = new Volunteer__c(Name='Vol1');
        insert v;

        Event__c e = new Event__c(Name='Ev1', Status__c='Scheduled');
        insert e;

        Volunteer_Event__c ve1 = new Volunteer_Event__c(Volunteer__c=v.Id, Event__c=e.Id);
        insert ve1;

        Volunteer_Event__c ve2 = new Volunteer_Event__c(Volunteer__c=v.Id, Event__c=e.Id);

        Test.startTest();
        try {
            insert ve2;
            System.assert(false, 'Expected duplicate assignment error');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Volunteer is already exist in this event!'));
        }
        Test.stopTest();
    }
}