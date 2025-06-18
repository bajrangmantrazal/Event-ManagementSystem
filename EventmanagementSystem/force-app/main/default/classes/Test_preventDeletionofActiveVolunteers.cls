@isTest
private class Test_preventDeletionofActiveVolunteers {

    @isTest
    static void testPreventDeletionOfActiveVolunteer() {
        // Create Chapter
        Chapter__c chapter = new Chapter__c(Address__c = 'Delete Test Chapter');
        insert chapter;

        // Create Event (active)
        Event__c event = new Event__c(
            Name = 'Ongoing Event',
            Chapter__c = chapter.Id,
            Status__c = 'Draft' // Not Completed or Cancelled
        );
        insert event;

        // Create Volunteer
        Volunteer__c volunteer = new Volunteer__c(Name = 'Active Volunteer');
        insert volunteer;

        // Link Volunteer to Event
        Volunteer_Event__c ve = new Volunteer_Event__c(
            Volunteer__c = volunteer.Id,
            Event__c = event.Id
        );
        insert ve;

        Test.startTest();
        try {
            delete volunteer;
            System.assert(false, 'Expected deletion to be blocked.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot delete volunteer with active event participation.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testAllowDeletionWhenNoActiveEvents() {
        // Create Chapter
        Chapter__c chapter = new Chapter__c(Address__c = 'Safe Delete Chapter');
        insert chapter;

        // Create Completed Event
        Event__c completedEvent = new Event__c(
            Name = 'Completed Event',
            Chapter__c = chapter.Id,
            Status__c = 'Completed'
        );
        insert completedEvent;

        // Create Volunteer
        Volunteer__c volunteer = new Volunteer__c(Name = 'Inactive Volunteer');
        insert volunteer;

        // Link Volunteer to Completed Event
        Volunteer_Event__c ve = new Volunteer_Event__c(
            Volunteer__c = volunteer.Id,
            Event__c = completedEvent.Id
        );
        insert ve;

        Test.startTest();
        delete volunteer; // Should succeed
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Volunteer__c WHERE Id = :volunteer.Id]);
    }
}