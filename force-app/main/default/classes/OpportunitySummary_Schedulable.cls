/*************************************************************************************
 * @Name         : OpportunitySummary_Schedulable.cls
 * @Description  : Apex Schedule Class To Invoke NotifyOpportunityAmounts_Batchable
 * @Created By   : Cem
 * @Created Date : 20.09.2021
 *************************************************************************************/

global class OpportunitySummary_Schedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        NotifyOpportunityAmounts_Batchable myBatch = new NotifyOpportunityAmounts_Batchable();
        Database.executeBatch(myBatch);
        
    }

}