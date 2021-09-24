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

         /* - Script to schedule batch class

        OpportunitySummary_Schedulable schObj = new OpportunitySummary_Schedulable();
        String dailyTenAm = '0 0 10 * * ?';
        String friOnePm = '0 0 13 ? * 6';
        String lastFri = '0 0 18 ? * 6L';
        System.schedule('Daily Job', dailyTenAm, schObj);
        System.schedule('Weekly Job', friOnePm, schObj);
        System.schedule('Monthly Job', lastFri, schObj);


        */

}