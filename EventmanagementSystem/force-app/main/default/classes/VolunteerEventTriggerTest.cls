@isTest
private class VolunteerEventTriggerTest {

    @isTest
    static void testVolunteerEventLimit_EnforcedAndBypassed() {
        // Create Chapter (required for Event__c)
        Chapter__c chapter = new Chapter__c(Address__c = 'Jaipur');
        insert chapter;

        // Create Events with "Planned" status
        List<Event__c> events = new List<Event__c>();
        for (Integer i = 1; i <= 6; i++) {
            events.add(new Event__c(
                Name = 'Event ' + i,
                Chapter__c = chapter.Id,
                Status__c = 'Draft'
            ));
        }
        insert events;

        // Create a volunteer
        Volunteer__c volunteer = new Volunteer__c(Name = 'Test Volunteer');
        insert volunteer;

        // Assign this volunteer to 5 active events
        List<Volunteer_Event__c> activeAssignments = new List<Volunteer_Event__c>();
        for (Integer i = 0; i < 5; i++) {
            activeAssignments.add(new Volunteer_Event__c(
                Volunteer__c = volunteer.Id,
                Event__c = events[i].Id
            ));
        }
        insert activeAssignments;

        // Test: Try to assign the 6th event, should trigger addError
        Volunteer_Event__c sixthAssignment = new Volunteer_Event__c(
            Volunteer__c = volunteer.Id,
            Event__c = events[5].Id
        );

        Test.startTest();
        try {
            insert sixthAssignment;
            System.assert(false, 'Expected exception not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Volunteer cannot be assigned to more than 5 active events.'));
        }
        Test.stopTest();

        // Test: Assign new volunteer to 1 event (should succeed)
        Volunteer__c newVolunteer = new Volunteer__c(Name = 'New Volunteer');
        insert newVolunteer;

        Volunteer_Event__c newAssignment = new Volunteer_Event__c(
            Volunteer__c = newVolunteer.Id,
            Event__c = events[0].Id
        );
        insert newAssignment;

        System.assertNotEquals(null, newAssignment.Id);
    }
}