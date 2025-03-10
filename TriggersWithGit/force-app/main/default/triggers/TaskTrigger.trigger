trigger TaskTrigger on Task (before insert,after update,after insert,before update) {

    if(Trigger.isAfter && Trigger.isUpdate)
    {
        TaskTriggerHandler.AfterUpdate(Trigger.New,Trigger.oldMap);
        TaskTriggerHandler.UpdateAccountRating(Trigger.New,Trigger.oldMap);
    }

    if(Trigger.isBefore && Trigger.isUpdate)
    {
        TaskTriggerHandler.AfterUpdate(Trigger.New,Trigger.oldMap);
        TaskTriggerHandler.UpdateAccountRating(Trigger.New,Trigger.oldMap);
    }
   
}