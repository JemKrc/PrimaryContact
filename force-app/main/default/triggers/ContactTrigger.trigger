trigger ContactTrigger on Contact (before update, before insert) {
    if(Trigger.IsBefore){
        if(Trigger.IsUpdate){
            ContactTriggerHandler.handleBeforeUpdate(Trigger.New);
        }
        if(Trigger.IsInsert){
            ContactTriggerHandler.handleBeforeInsert(Trigger.New);
        }
    }
}