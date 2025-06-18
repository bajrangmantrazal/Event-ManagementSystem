public class EventHoldStatusUpdateTriggerHandler {
    Boolean isExecuting;
    Integer size;
    List<Event__c> newList;
    Map<Id, Event__c> oldMap;

    public EventHoldStatusUpdateTriggerHandler(
        Boolean isExecuting,
        Integer size,
        List<Event__c> newList,
        Map<Id, Event__c> oldMap
    ) {
        this.isExecuting = isExecuting;
        this.size = size;
        this.newList = newList;
        this.oldMap = oldMap;
    }

    public void afterUpdate() {
        if (EventTriggerControl.hasHandledHoldPropagation) return;
        EventTriggerControl.hasHandledHoldPropagation = true;

        Set<Id> holdChangedParentEventIds = new Set<Id>();
        Set<Id> holdChangedChildEventIds = new Set<Id>();

        for (Event__c evt : newList) {
            Event__c oldEvt = oldMap.get(evt.Id);
            if (oldEvt == null) continue;

            if (evt.Status__c == 'Hold' && oldEvt.Status__c != 'Hold') {
                holdChangedParentEventIds.add(evt.Id);
                holdChangedChildEventIds.add(evt.Id);
            }
        }

        List<Event__c> childUpdates = new List<Event__c>();
        if (!holdChangedParentEventIds.isEmpty()) {
            List<Event_Dependencies__c> dependencies = [
                SELECT Dependent_Event__r.Id, Dependent_Event__r.Status__c
                FROM Event_Dependencies__c
                WHERE Event__c IN :holdChangedParentEventIds
            ];

            for (Event_Dependencies__c dep : dependencies) {
                Event__c child = dep.Dependent_Event__r;
                if (child != null && child.Status__c != 'Hold') {
                    childUpdates.add(new Event__c(Id = child.Id, Status__c = 'Hold'));
                }
            }
        }

        List<Event__c> parentUpdates = new List<Event__c>();
        if (!holdChangedChildEventIds.isEmpty()) {
            List<Event_Dependencies__c> links = [
                SELECT Event__c, Dependent_Event__r.Status__c
                FROM Event_Dependencies__c
                WHERE Dependent_Event__c IN :holdChangedChildEventIds
            ];

            Set<Id> parentIdsToCheck = new Set<Id>();
            for (Event_Dependencies__c link : links) {
                if (link.Event__c != null) {
                    parentIdsToCheck.add(link.Event__c);
                }
            }

            if (!parentIdsToCheck.isEmpty()) {
                List<Event_Dependencies__c> allDeps = [
                    SELECT Event__c, Dependent_Event__r.Status__c
                    FROM Event_Dependencies__c
                    WHERE Event__c IN :parentIdsToCheck
                ];

                Map<Id, List<String>> parentToStatuses = new Map<Id, List<String>>();
                for (Event_Dependencies__c dep : allDeps) {
                    if (!parentToStatuses.containsKey(dep.Event__c)) {
                        parentToStatuses.put(dep.Event__c, new List<String>());
                    }
                    parentToStatuses.get(dep.Event__c).add(dep.Dependent_Event__r.Status__c);
                }

                for (Id parentId : parentToStatuses.keySet()) {
                    Boolean allHold = true;
                    for (String status : parentToStatuses.get(parentId)) {
                        if (status != 'Hold') {
                            allHold = false;
                            break;
                        }
                    }
                    if (allHold) {
                        parentUpdates.add(new Event__c(Id = parentId, Status__c = 'Hold'));
                    }
                }
            }
        }

        if (!childUpdates.isEmpty()) {
            update childUpdates;
        }
        if (!parentUpdates.isEmpty()) {
            update parentUpdates;
        }
    }
}