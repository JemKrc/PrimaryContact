/*************************************************************************************
 * @Name         : TestNotifyOpportunityAmounts_Batchable.cls
 * @Description  : Test class for NotifyOpportunityAmounts_Batchable
 * @Created By   : Cem
 * @Created Date : 22.09.2021
 *************************************************************************************/

@isTest
public class TestNotifyOpportunityAmounts_Batchable {
    //field for threestages test
    private static Account testAcc;
    //fields for sum of amount test
    private static Account testSum;
    private static Opportunity testOpp;
    //field for update test
    private static Opportunity updateOpp;
    
    private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'testOnlyThreeStageNamesAffected' {
                
				//Dummy account for test
                Account accTest = new Account(Name= 'AccountTest');
                insert accTest;
                testAcc = accTest;
                //Dummy opportunities for test
                Opportunity oppTest1 = new Opportunity(Name ='oppTest1', AccountId = accTest.Id, Amount = 30000, StageName = 'Prospecting', CloseDate = Date.newInstance(2021, 10, 15));
                insert oppTest1;
                Opportunity oppTest2 = new Opportunity(Name ='oppTest2', AccountId = accTest.Id, Amount = 20000, StageName = 'Closed Won', CloseDate = Date.newInstance(2021, 10, 15));
                insert oppTest2;
                Opportunity oppTest3 = new Opportunity(Name ='oppTest3', AccountId = accTest.Id, Amount = 10000, StageName = 'Closed Lost', CloseDate = Date.newInstance(2021, 10, 15));
                insert oppTest3;
                Opportunity oppTest4 = new Opportunity(Name ='oppTest4', AccountId = accTest.Id, Amount = 40000, StageName = 'Open', CloseDate = Date.newInstance(2021, 10, 15));
                insert oppTest4;

                

            }
            when 'testCalculatesSumOfAmounts' {
                //Dummy account for test
                Account sumAcc = new Account(Name = 'SumAcc');
                insert sumAcc;
                //Opportunities for this test
                Opportunity sumOpp1 = new Opportunity(Name ='SumOpp1', AccountId = sumAcc.Id, Amount = 30000, StageName = 'Closed Won', CloseDate = Date.newInstance(2021, 10, 15));
				insert sumOpp1;
                Opportunity sumOpp2 = new Opportunity(Name ='SumOpp2', AccountId = sumAcc.Id, Amount = 30000, StageName = 'Closed Won', CloseDate = Date.newInstance(2021, 10, 15));
                insert sumOpp2;
                
                testOpp = sumOpp1;
                testSum = sumAcc;
            }
            when 'tetsForUpdateAddsToSum' {
                //Dummy account for this test
                Account primaryAcc = new Account(Name = 'Primal');
                insert primaryAcc;
                //related opportunities for this test
                Opportunity priOpp1 = new Opportunity(Name ='PriOpp1', AccountId = primaryAcc.Id, Amount = 30000, StageName = 'Closed Won', CloseDate = Date.newInstance(2021, 10, 15));
				insert priOpp1;
                Opportunity priOpp2 = new Opportunity(Name ='SumOpp2', AccountId = primaryAcc.Id, Amount = 30000, StageName = 'Closed Won', CloseDate = Date.newInstance(2021, 10, 15));
                insert priOpp2;
                updateOpp = priOpp1;
                //Related contacts for this test
                Contact primaryCon = new Contact(LastName = 'Primary', AccountId = primaryAcc.Id, Is_Primary_Contact__c = true, Email = 'test@test.com');
                insert primaryCon;
                Contact nonPrimary = new Contact(LastName='NonPrimary', AccountId = primaryAcc.Id, Is_Primary_Contact__c = false);
                insert nonPrimary;

            }
        }
    }

    //To test query only takes certain stage names for an opportunity
    @isTest
    private static void testOnlyThreeStageNamesAffected() {
        //initialize
        initData('testOnlyThreeStageNamesAffected');
		
        //start test
        Test.startTest();
		//test
        NotifyOpportunityAmounts_Batchable testBatch = new NotifyOpportunityAmounts_Batchable();
        Database.executeBatch(testBatch);
        //stop test
        Test.stopTest();
        
        //Assert only three of the opportunities affected
        System.assertEquals(3, NotifyOpportunityAmounts_Batchable.mapForTest.get(testAcc.Id).keySet().size());

    }

    //To test if there are two stages with same name created. Class calculates sum
    @isTest
    private static void testCalculatesSumOfAmounts() {
        //initialize
        initData('testCalculatesSumOfAmounts');
        
        //Start test
        Test.startTest();
        //Test
        NotifyOpportunityAmounts_Batchable testBatch = new NotifyOpportunityAmounts_Batchable();
        Database.executeBatch(testBatch);
        //Stop test
        Test.stopTest();
        
        //Assert total amount is calculated
        System.assertEquals(60000, NotifyOpportunityAmounts_Batchable.mapForTest.get(testOpp.AccountId).get(testOpp.StageName));

    }

    //Updating existing opportunity will added to sum 
    @isTest
    private static void tetsForUpdateAddsToSum() {
        //Initialize
        initData('tetsForUpdateAddsToSum');
        
        //Update an opportunity for this account
        updateOpp.Amount = 10000;
        update updateOpp;
        //Start test
        Test.startTest();
        //Test
        NotifyOpportunityAmounts_Batchable testBatch = new NotifyOpportunityAmounts_Batchable();
        Database.executeBatch(testBatch);
        //Stop test
        Test.stopTest();
        
        //Assert takes the updated amount for calculation
        System.assertEquals(40000, NotifyOpportunityAmounts_Batchable.mapForTest.get(updateOpp.AccountId).get(updateOpp.StageName));
        //Assert there is only one stage name for this opportunity summary
        System.assertEquals(1, NotifyOpportunityAmounts_Batchable.mapForTest.get(updateOpp.AccountId).keySet().size());
    }

}