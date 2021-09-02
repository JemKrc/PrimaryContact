@isTest
private class ExtensionControllerTest {
    public String searchText {get;set;}
    private static Account refAcct;
    private static Contact refCon;
    private static Account failAct;
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
               
                refAcct = acct;
                refCon = testCon2;
            }
         
            when 'testMethodNameFailure' {
                
                //Dummy account to use for failing test
                Account testacct = new Account(Name='FailAcc');
                insert testacct;

                failAct = testacct;
			}
        }
}
    
    //Testing setPrimary() method
    @isTest
    private static void testsetPrimarySuccess() {
        initData('testMethodNameSuccess');
        
         
               //call the current page for testing and attaching values
               PageReference testPage = Page.PrimaryContact; 
               Test.setCurrentPage(testPage);
               testPage.getParameters().put('Id', String.valueOf(refAcct.Id));
               testPage.getParameters().put('contactId', String.valueOf(refCon.Id));

                
         //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);

        //Get the Standard Controller and pass it to controller extension
        ExtentionController ext = new ExtentionController(accountController);
        
        Test.startTest();
        //Testing
        ext.setPrimary();
        
        Test.stopTest();
        
        //Assertions
        Contact assertCon = [Select LastName, Is_Primary_Contact__c FROM Contact WHERE LastName='TestCon2'];
        System.assert(assertCon.Is_Primary_Contact__c == true);
        

    }
    
    //Testing search() method
    @isTest 
    private static void testsearchSuccess()
    {   
        initData('testMethodNameSuccess');
        
        
        List<Contact> Cons = [Select Id, LastName, Is_Primary_Contact__c FROM Contact WHERE LastName Like '%TestCon%'];
        
         
        String sText = 'TestCon';
        
        PageReference searchPage = Page.PrimaryContact; 
               Test.setCurrentPage(searchPage);
               searchPage.getParameters().put('Id', String.valueOf(refAcct.Id));
               searchPage.getParameters().put('searchText',sText);
               
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);

        //Get the Standard Controller and pass it to controller extension
        ExtentionController ext = new ExtentionController(accountController);
        
        //setting ContactMap to dummy values
        ext.extContacts = Cons;
        
        //Test
        Test.startTest();
        
        PageReference ref = ext.search();
        
        Test.stopTest();
        
        //Assert
        System.assertEquals(4,ext.extContacts.size());
    }
    
    //Test that will fail
     @isTest
    private static void testMethodNameFailure() {
        initData('testMethodNameFailure');
        
        
        String sText = 'TestC';        
        PageReference failPage = Page.PrimaryContact; 
               Test.setCurrentPage(failPage);
               failPage.getParameters().put('Id', String.valueOf(failAct.Id));
               failPage.getParameters().put('searchText',sText);
        
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(failAct);

        //Get the Standard Controller and pass it to controller extension
        ExtentionController ext = new ExtentionController(accountController);
        
        //Setting ContactMap to null
        ext.extContacts = null;
        
        //Feeding with null Map<Integer, Contact>
        Test.startTest();
        
        ext.search();
        
        Test.stopTest();
        
        //Assertion
        System.assertEquals(4, ext.extContacts.size());
    }
    
}