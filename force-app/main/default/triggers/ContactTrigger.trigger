/*************************************************************************************
 * @Name         : ContactTrigger.trigger
 * @Description  : Apex Trigger for Contact
 * @Created By   : Cem
 * @Created Date : 15.09.2021
 *************************************************************************************/

trigger ContactTrigger on Contact (before update, before insert) {
    if(Trigger.IsBefore) {
        if(Trigger.IsUpdate || Trigger.IsInsert) {
            ContactTriggerHandler.handleBeforeUpdateInsert(Trigger.New, Trigger.oldMap);
        }
      
    }
}