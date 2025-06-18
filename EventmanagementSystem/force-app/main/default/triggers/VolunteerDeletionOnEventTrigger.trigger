trigger VolunteerDeletionOnEventTrigger on Volunteer__c (before delete) {
    VolunteerDeletionOnEventTriggerHandler handler = new VolunteerDeletionOnEventTriggerHandler(
        Trigger.isExecuting,
        Trigger.size,
        Trigger.oldMap,
        Trigger.old
    );

    try {
        switch on Trigger.operationType {
            when BEFORE_DELETE {
                handler.beforeDelete();
            }
        }
    } catch (Exception ex) {
        throw ex;
    }
}