trigger VolunteerLimitationOnEventTrigger on Volunteer_Event__c (before insert) {
    VolunteerLimitationOnEventTriggerHandler handler = new VolunteerLimitationOnEventTriggerHandler(
        Trigger.isExecuting,
        Trigger.size,
        Trigger.new
    );

    try {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }
        }
    } catch (Exception ex) {
        throw ex;
    }
}