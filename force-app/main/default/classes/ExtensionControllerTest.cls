@isTest
private class ExtensionControllerTest {
    public String searchText {get;set;}
	private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'testMethodNameSuccess' {
                
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
                contacts.add(testCon1);
                contacts.add(testCon2);
                contacts.add(testCon3);
                contacts.add(testCon4);
                insert contacts;
               
            }
         
            when 'testMethodNameFailure' {
                
                //Dummy account to use for failing test
                Account testacct = new Account(Name='FailAcc');
                insert testacct;
			}
        }
}
    
    //Testing setPrimary() method
    @isTest
    private static void testsetPrimarySuccess() {
        initData('testMethodNameSuccess');
        
         Account refAcct = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount'];
         Contact refCon = [SELECT Id, LastName, Is_Primary_Contact__c FROM Contact WHERE LastName = 'TestCon2'];
        
               //call the current page for testing and attaching values
               PageReference testPage = Page.PrimaryContact; 
               Test.setCurrentPage(testPage);
               testPage.getParameters().put('Id', String.valueOf(refAcct.Id));
               testPage.getParameters().put('contactId', String.valueOf(refCon.Id));

                
         //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);

        //Get the Standard Controller and pass it to controller extension
        extentionController ext = new extentionController(accountController);
        
        Test.startTest();
        //Testing
        PageReference ref = ext.setPrimary();
        
        Test.stopTest();
        
        //Assertions
        Contact assertCon = [Select LastName, Is_Primary_Contact__c FROM Contact WHERE LastName='TestCon2'];
        System.assert(assertCon.Is_Primary_Contact__c == true);
        System.assertEquals('/apex/PrimaryContact?id='+refAcct.Id, ref.getUrl());

    }
    
    //Testing search() method
    @isTest 
    private static void testsearchSuccess()
    {   
        initData('testMethodNameSuccess');
        Account searchAcc = [SELECT Id, Name FROM Account Where Name = 'TestAccount'];
        
        List<Contact> Cons = [Select Id, LastName, Is_Primary_Contact__c FROM Contact WHERE LastName Like '%TestCon%'];
        Map<Integer, Contact> ContMap = new Map<Integer, Contact>();
                for(Integer index = 0 ; index < Cons.size(); index++) {
                    ContMap.put(index, Cons[index]);}
         
        String sText = 'TestC';
        
        PageReference searchPage = Page.PrimaryContact; 
               Test.setCurrentPage(searchPage);
               searchPage.getParameters().put('Id', String.valueOf(searchAcc.Id));
               searchPage.getParameters().put('searchText',sText);
               
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(searchAcc);

        //Get the Standard Controller and pass it to controller extension
        extentionController ext = new extentionController(accountController);
        
        //setting ContactMap to dummy values
        ext.ContactMap = ContMap;
        
        //Test
        Test.startTest();
        
        PageReference ref = ext.search();
        
        Test.stopTest();
        
        //Assert
        System.assertEquals(null, ref);
    }
    
    //Test that will fail
     @isTest
    private static void testMethodNameFailure() {
        initData('testMethodNameFailure');
        Account failAct = [SELECT Id, Name FROM Account WHERE Name = 'FailAcc'];
        
        String sText = 'TestC';        
        PageReference failPage = Page.PrimaryContact; 
               Test.setCurrentPage(failPage);
               failPage.getParameters().put('Id', String.valueOf(failAct.Id));
               failPage.getParameters().put('searchText',sText);
        
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(failAct);

        //Get the Standard Controller and pass it to controller extension
        extentionController ext = new extentionController(accountController);
        
        //Setting ContactMap to null
        ext.ContactMap = null;
        
        //Feeding with null Map<Integer, Contact>
        Test.startTest();
        
        ext.search();
        
        Test.stopTest();
        
        //Assertion
        System.assertEquals('/apex/PrimaryContact?id='+failAct.Id, ext.search().getUrl());

    }
    
}