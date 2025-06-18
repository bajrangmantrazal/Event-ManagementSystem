trigger EventHoldStatusUpdateTrigger on Event__c (after update) {
    EventHoldStatusUpdateTriggerHandler handler = new EventHoldStatusUpdateTriggerHandler(
        Trigger.isExecuting,
        Trigger.size,
        Trigger.new,
        Trigger.oldMap
    );

    try {
        switch on Trigger.operationType {
            when AFTER_UPDATE {
                handler.afterUpdate();
            }
        }
    } catch (Exception ex) {
        throw ex;
    }
}