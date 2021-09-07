/*************************************************************************************
 * @Name         : PrimaryContactControllerTest.cls
 * @Description  : Test class for PrimaryContactController
 * @Created By   : Cem
 * @Created Date : 07.09.2021
 *************************************************************************************/

@isTest
private class PrimaryContactControllerTest {
    public String searchText {get;set;}
    private static Account refAcct;
    private static Contact refCon;
    private static Account failAct;
    
	private static void initData(String actionToDo) {
        
        switch on actionToDo {
            when 'testSetPrimarySuccess' {
                
                //Dummy Account for test
                Account acct = new Account();
                acct.Name = 'TestAccount';
                insert acct;
                
                //Realted dummy Contacts for test
                List<Contact> contacts = new List<Contact>();
                Contact testCon1 = new Contact(LastName = 'TestCon1', AccountId = acct.Id, Is_Primary_Contact__c = true);
                Contact testCon2 = new Contact(LastName = 'TestCon2', AccountId = acct.Id, Is_Primary_Contact__c = false);
                Contact testCon3 = new Contact(LastName = 'TestCon3', AccountId = acct.Id);
                Contact testCon4 = new Contact(LastName = 'TestCon4', AccountId = acct.Id);
                contacts.add(testCon1);
                contacts.add(testCon2);
                contacts.add(testCon3);
                contacts.add(testCon4);
                insert contacts;
                
                refAcct = acct;
                refCon = testCon2;
            }
            when 'testSearchSuccess' {
                //Dummy Account for test
                Account acct = new Account();
                acct.Name = 'TestAccount';
                insert acct;
                
                //Realted dummy Contacts for test
                List<Contact> contacts = new List<Contact>();
                Contact testCon1 = new Contact(LastName = 'TestCon1', AccountId = acct.Id);
                Contact testCon2 = new Contact(LastName = 'TestCon2', AccountId = acct.Id);
                Contact testCon3 = new Contact(LastName = 'TestCon3', AccountId = acct.Id);
                Contact testCon4 = new Contact(LastName = 'TestCon4', AccountId = acct.Id);
                Contact testCont5 = new Contact(LastName = 'NotToBeSearched',  AccountId = acct.Id);
                contacts.add(testCon1);
                contacts.add(testCon2);
                contacts.add(testCon3);
                contacts.add(testCon4);
                contacts.add(testCont5);
                insert contacts;
                
                refAcct = acct;
                refCon = testCon2;
                
            }
         
            when 'testSearchFailure' {
                
                //Dummy account to use for failing test
                failAct = new Account(Name='FailAcc');
                insert failAct;
            }
        }
    }
    
    //Testing setPrimary() method
    @isTest
    private static void testSetPrimarySuccess() {
        initData('testSetPrimarySuccess');
        
        //call the current page for testing and attaching values
        PageReference testPage = Page.PrimaryContact;
        Test.setCurrentPage(testPage);
        
        //create a standard controller and pass the dummy account controller       
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);       
        //Get the Standard Controller and pass it to controller extension  
        PrimaryContactController ext = new PrimaryContactController(accountController); 
        
        Test.startTest();
        //Testing
        ext.accountRecord = refAcct;
        ext.primaryContactId = refCon.Id;
        ext.setPrimary();
        Test.stopTest();
              
        //Assertions
        Contact assertCon = [Select LastName, Is_Primary_Contact__c FROM Contact WHERE LastName='TestCon2'];
        System.assert(assertCon.Is_Primary_Contact__c);

    }
    
    //Testing search() method
    @isTest 
    private static void testSearchSuccess() {   
        initData('testSearchSuccess');
        PageReference searchPage = Page.PrimaryContact; 
        Test.setCurrentPage(searchPage);
        
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);

        //Get the Standard Controller and pass it to controller extension
        PrimaryContactController ext = new PrimaryContactController(accountController);
        
        Test.startTest();
            ext.searchText = 'TestCon';
            ext.getRelatedContacts();
        Test.stopTest();
        //Assert
        System.assertEquals(4,ext.contacts.size());
    }
    
    //Test that will fail
    @isTest
    private static void testSearchFailure() {
        initData('testSearchFailure');
        
        PageReference failPage = Page.PrimaryContact; 
        Test.setCurrentPage(failPage);
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(failAct);

        //Get the Standard Controller and pass it to controller extension
        PrimaryContactController ext = new PrimaryContactController(accountController);
        
        //Feeding with null List<Contact>
        Test.startTest();
            ext.accountRecord = null;
            ext.getRelatedContacts();
        Test.stopTest();
        
        //Assertion
        System.assertEquals(ext.contacts.size(), 0);

    }
    
}