@isTest
private class PrimaryContactControllerTest {
    public String searchText {get;set;}
    private static Account refAcct;
    private static Contact refCon;
    private static Account failAct;
	private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'testSetPrimarySuccess','testSearchSuccess' {
                
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
         
            when 'searchMethodFailure' {
                
                //Dummy account to use for failing test
                Account testacct = new Account(Name='FailAcc');
                insert testacct;

                failAct = testacct;
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
               testPage.getParameters().put('Id', String.valueOf(refAcct.Id));
               testPage.getParameters().put('contactId', String.valueOf(refCon.Id));

                
         //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);

        //Get the Standard Controller and pass it to controller extension
        PrimaryContactController ext = new PrimaryContactController(accountController);
        
        Test.startTest();
        //Testing
        ext.setPrimary();
        
        Test.stopTest();
        
        //Assertions
        Contact assertCon = [SELECT LastName, Is_Primary_Contact__c FROM Contact WHERE LastName='TestCon2'];
        System.assert(assertCon.Is_Primary_Contact__c == true);
        

    }
    
    //Testing search() method
    @isTest 
    private static void testSearchSuccess()
    {   
        initData('testSearchSuccess');
        
        
        List<Contact> Cons = [SELECT Id, LastName, Is_Primary_Contact__c FROM Contact WHERE LastName Like '%TestCon%'];
        
        Contact notCon = new Contact(LastName = 'NotToBeSearched');
        Cons.add(notCon);
         
        String sText = 'TestCon';
        
        PageReference searchPage = Page.PrimaryContact; 
               Test.setCurrentPage(searchPage);
               searchPage.getParameters().put('Id', String.valueOf(refAcct.Id));
               searchPage.getParameters().put('searchText',sText);
               
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);

        //Get the Standard Controller and pass it to controller extension
        PrimaryContactController ext = new PrimaryContactController(accountController);
        
        //setting ContactMap to dummy values
        ext.extContacts = Cons;
        
        //Test
        Test.startTest();
        
        PageReference ref = ext.search();
        
        Test.stopTest();
        
        //Assert
        //Showing 4 not 5 - passes
        System.assertEquals(4,ext.extContacts.size());
    }
    
    //Test that will fail
     @isTest
    private static void searchMethodFailure() {
        initData('searchMethodFailure');
        
        
        String sText = 'TestC';        
        PageReference failPage = Page.PrimaryContact; 
               Test.setCurrentPage(failPage);
               failPage.getParameters().put('Id', String.valueOf(failAct.Id));
               failPage.getParameters().put('searchText',sText);
        
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(failAct);

        //Get the Standard Controller and pass it to controller extension
        PrimaryContactController ext = new PrimaryContactController(accountController);
        
        //Setting ContactMap to null
        ext.extContacts = null;
        
        //Feeding with null Map<Integer, Contact>
        Test.startTest();
        
        ext.search();
        
        Test.stopTest();
        
        //Assertions
        //Passes
        System.assertEquals(ext.extContacts == new List<Contact>());
        //Fails
        System.assertEquals(ext.extContacts != new List<Contact>());
    }
    
}