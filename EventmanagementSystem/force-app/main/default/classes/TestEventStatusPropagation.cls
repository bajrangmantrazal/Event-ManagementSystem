@isTest
public class TestEventStatusPropagation {

    @isTest
    static void testParentHoldUpdatesChildren() {
        // Create a Chapter if required
        Chapter__c chapter = new Chapter__c(Address__c = 'Test Address');
        insert chapter;

        // Create parent and child events
        Event__c parentEvent = new Event__c(Name = 'Parent Event', Status__c = 'Draft', Chapter__c = chapter.Id);
        Event__c childEvent1 = new Event__c(Name = 'Child Event 1', Status__c = 'Draft', Chapter__c = chapter.Id);
        Event__c childEvent2 = new Event__c(Name = 'Child Event 2', Status__c = 'Draft', Chapter__c = chapter.Id);
        insert new List<Event__c>{ parentEvent, childEvent1, childEvent2 };

        // Create dependencies (Event__c = parent, Dependent_Event__c = child)
        insert new List<Event_Dependencies__c>{
            new Event_Dependencies__c(Event__c = parentEvent.Id, Dependent_Event__c = childEvent1.Id),
            new Event_Dependencies__c(Event__c = parentEvent.Id, Dependent_Event__c = childEvent2.Id)
        };

        // Set parent to Hold and trigger the logic
        parentEvent.Status__c = 'Hold';
        Test.startTest();
        update parentEvent;
        Test.stopTest();

        // Query children to verify status
        List<Event__c> updatedChildren = [
            SELECT Id, Name, Status__c FROM Event__c 
            WHERE Id IN :new List<Id>{childEvent1.Id, childEvent2.Id}
        ];

        for (Event__c child : updatedChildren) {
            System.assertEquals('Hold', child.Status__c, 'Child event should be updated to Hold');
        }
    }

    @isTest
    static void testAllChildrenHoldUpdatesParent() {
        // Create Chapter
        Chapter__c chapter = new Chapter__c(Address__c = 'Another Address');
        insert chapter;

        // Create parent and children
        Event__c parentEvent = new Event__c(Name = 'Parent Event 2', Status__c = 'Draft', Chapter__c = chapter.Id);
        Event__c childEvent1 = new Event__c(Name = 'Child Event 3', Status__c = 'Draft', Chapter__c = chapter.Id);
        Event__c childEvent2 = new Event__c(Name = 'Child Event 4', Status__c = 'Draft', Chapter__c = chapter.Id);
        insert new List<Event__c>{ parentEvent, childEvent1, childEvent2 };

        // Establish dependencies (Event__c = parent, Dependent_Event__c = child)
        insert new List<Event_Dependencies__c>{
            new Event_Dependencies__c(Event__c = parentEvent.Id, Dependent_Event__c = childEvent1.Id),
            new Event_Dependencies__c(Event__c = parentEvent.Id, Dependent_Event__c = childEvent2.Id)
        };

        // Update both children to Hold
        childEvent1.Status__c = 'Hold';
        childEvent2.Status__c = 'Hold';
        Test.startTest();
        update new List<Event__c>{childEvent1, childEvent2};
        Test.stopTest();

        // Verify parent status
        Event__c updatedParent = [SELECT Id, Status__c FROM Event__c WHERE Id = :parentEvent.Id];
        System.assertEquals('Hold', updatedParent.Status__c, 'Parent should be updated to Hold if all children are on Hold');
    }
}