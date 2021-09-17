/*************************************************************************************
 * @Name         : TestContactTrigger.cls
 * @Description  : Test class for ContactTrigger
 * @Created By   : Cem
 * @Created Date : 16.09.2021
 *************************************************************************************/

@isTest
private class TestContactTrigger {
    //fields for update with primary contact
    private static Account accForPrimary;
    private static Contact testPrimaryContact;
    private static Contact testRegular;
    //fields for update with no primary contact
    private static Account accWithNoPrimary;
    private static Contact testNonPrimaryCon;
    //field for insert with no primary
    private static Account accWithNoPrimaryInsert;
    //field for insert with primary
    private static Account accWithPrimaryInsert;
    //fields for multiple accounts
    private static Account accOne;
    private static Account accTwo;
    private static Contact conOne;
    private static Contact conTwo;
    //fields for updatePrimaryContactPhone
    private static List<Contact> contsListForFuture;
    private static Account accForFuture;


    private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'testUpdateWithPrimaryContact' {
                
                //create dummy account for test
                Account accWithPrimary = new Account(name = 'AccountWithPrimaryContact');
                insert accWithPrimary;
                

                //create contacts that are realated to dummy account
                List<Contact> contactsWithPrimary = new List<Contact>{
                    new Contact(LastName = 'TestCont1',Is_Primary_Contact__c = false, AccountId = accWithPrimary.Id),
                	new Contact(LastName = 'TestCont2', Is_Primary_Contact__c = false, AccountId = accWithPrimary.Id),
                    new Contact(LastName = 'TestCont3', Is_Primary_Contact__c = false, AccountId = accWithPrimary.Id)};
                    
                //Primary Contact. Phone will be changed to see if update succeeds
                Contact primaryContact = new Contact(LastName = 'TestCont4', 
                                                         Is_Primary_Contact__c = true,
                                                         AccountId = accWithPrimary.Id, Phone = '555-444');
                
                //Updating this contact won't effect anything
                Contact regularContact = new Contact(LastName = 'NonEffective',Is_Primary_Contact__c = false, AccountId = accWithPrimary.Id);

                insert regularContact;
                insert contactsWithPrimary;
                insert primaryContact;
                
                testRegular = regularContact;
                testPrimaryContact = primaryContact;
                accForPrimary = accWithPrimary;

            }
            when 'testUpdateWithNoPrimaryContact' {
                
                //Dummy account for testUpdateWithNoPrimaryContact
                Account accNoPrimary = new Account(Name='WithNoPrimaryContact');
                insert accNoPrimary;
                
                //Dummy contacts for testUpdateWithNoPrimaryContact
                List<Contact> contactsWithNoPrimary = new List<Contact>{
                	new Contact(LastName = 'TestCont2', Is_Primary_Contact__c = false, AccountId = accNoPrimary.Id),
                    new Contact(LastName = 'TestCont3', Is_Primary_Contact__c = false, AccountId = accNoPrimary.Id),
                    new Contact(LastName = 'TestCont4', Is_Primary_Contact__c = false, AccountId = accNoPrimary.Id)};
                 Contact notPrimary = new Contact(LastName = 'TestCont1',Is_Primary_Contact__c = false, Phone = '345-8439', AccountId = accNoPrimary.Id);        
                 insert notPrimary;
                 insert contactsWithNoPrimary;
                
                 testNonPrimaryCon = notPrimary;
                 accWithNoPrimary = accNoPrimary;
            }
            
            when 'testInsertWithPrimaryContact' {
                
                //Dummy account for testInsertWithPrimary
                Account accPrimaryInsert = new Account(Name='WithPrimaryContactInsert');
                insert accPrimaryInsert;
                
                //Dummy contacts for testInsertWithPrimary
                List<Contact> contactsWithPrimaryInsert = new List<Contact>{
                	new Contact(LastName = 'TestCont2', Is_Primary_Contact__c = false, AccountId = accPrimaryInsert.Id),
                    new Contact(LastName = 'TestCont3', Is_Primary_Contact__c = false, AccountId = accPrimaryInsert.Id),
                    new Contact(LastName = 'TestCont4', Is_Primary_Contact__c = true, Phone = '444', AccountId = accPrimaryInsert.Id)};
               
                 insert contactsWithPrimaryInsert;
                
                 accWithPrimaryInsert = accPrimaryInsert;

            }
            when 'testInsertWithNoPrimaryContact' {
                
                //Duumy Account for testInsertWithNoPrimary
                Account accNoPrimaryInsert = new Account(Name='WithNoPrimaryContactInsert');
                insert accNoPrimaryInsert;
                
                //Dummy contacts for testInsertWithNoPrimary
                List<Contact> contactsWithNoPrimaryInsert = new List<Contact>{
                	new Contact(LastName = 'TestCont2', Is_Primary_Contact__c = false, AccountId = accNoPrimaryInsert.Id),
                    new Contact(LastName = 'TestCont3', Is_Primary_Contact__c = false, AccountId = accNoPrimaryInsert.Id),
                    new Contact(LastName = 'TestCont4', Is_Primary_Contact__c = false, AccountId = accNoPrimaryInsert.Id)};
               
                 insert contactsWithNoPrimaryInsert;
                
                 accWithNoPrimaryInsert = accNoPrimaryInsert;

            }
            when 'testForMultipleAccounts' {
                
                //Accounts to test for multiple account test
                Account multiOne = new Account(Name = 'TestAccOne');
                insert multiOne;
                Account multiTwo = new Account(Name = 'TestAccTwo');
                insert multiTwo;
                
                //Contact Lists and primary contacts for multiple account test
                List<Contact> contactsForMultiOne = new List<Contact>{
                	new Contact(LastName = 'TestCont1', Is_Primary_Contact__c = false, AccountId = multiOne.Id),
                    new Contact(LastName = 'TestCont2', Is_Primary_Contact__c = false, AccountId = multiOne.Id),
                    new Contact(LastName = 'TestCont3', Is_Primary_Contact__c = false, AccountId = multiOne.Id)};
                Contact multiOnePrimary = new Contact(LastName = 'TestAccountContact', 
                                                      Is_Primary_Contact__c = true, Phone = '444',
                                                      AccountId = multiOne.Id);
                insert contactsForMultiOne;
                insert multiOnePrimary;
                
                conOne = multiOnePrimary;
                accOne = multiOne;
                        
         		List<Contact> contactsForMultiTwo = new List<Contact>{
                	new Contact(LastName = 'TestCont4', Is_Primary_Contact__c = false, AccountId = multiTwo.Id),
                    new Contact(LastName = 'TestCont5', Is_Primary_Contact__c = false, AccountId = multiTwo.Id),
                    new Contact(LastName = 'TestCont6', Is_Primary_Contact__c = false, AccountId = multiTwo.Id)};
                Contact multiTwoPrimary = new Contact(LastName = 'TestCont', 
                                                      Is_Primary_Contact__c = true, Phone = '999',
                                                      AccountId = multiTwo.Id);
                insert contactsForMultiTwo;
                insert multiTwoPrimary;
                
                conTwo = multiTwoPrimary;
                accTwo = multiTwo;
      

            }
            when 'testUpdatePrimaryContactPhone' {
                //Dummy account for test
                Account futureAcc = new Account(Name='FutureMethodAcc');
                insert futureAcc;
                //related contacts for test
                List<Contact> contactsForAsync = new List<Contact>{
                    new Contact(LastName = 'TestCont7',Is_Primary_Contact__c = false, AccountId = futureAcc.Id),
                	new Contact(LastName = 'TestCont8', Is_Primary_Contact__c = false, AccountId = futureAcc.Id),
                    new Contact(LastName = 'TestCont9', Is_Primary_Contact__c = false, AccountId = futureAcc.Id),
                    new Contact(LastName = 'TestCont10', Is_Primary_Contact__c = true, Phone = '590', AccountId = futureAcc.Id)};
                insert contactsForAsync;
                
                accForFuture = futureAcc;
                contsListForFuture = contactsForAsync;

            }
        }
    }

    //Changing the phone number of existing primary contact
    //And updating a non-primary contact to see there is no effect on others
    @isTest
    private static void testUpdateWithPrimaryContact() {
        //Initialize
        initData('testUpdateWithPrimaryContact');

        //Start test
        Test.startTest();
        //Test
        testRegular.Phone = '8908';
        update testRegular;
        
        testPrimaryContact.Phone = '555-777';
        update testPrimaryContact;
        //Stop Test
        Test.stopTest();

        //Retrieve data for assertion
        Contact assertCon = [SELECT Id, LastName, Primary_Contact_Phone__c
                             FROM Contact 
                             WHERE LastName = 'TestCont2'
                             AND AccountId = :accForPrimary.Id];
        Contact assertConReg = [SELECT Id, LastName, Primary_Contact_Phone__c
                             	FROM Contact 
                             	WHERE LastName = 'NonEffective'
                             	AND AccountId = :accForPrimary.Id];
        
        //Assertions
        System.assertEquals('555-777', assertCon.Primary_Contact_Phone__c);
        System.assertEquals('555-777', assertConReg.Primary_Contact_Phone__c);

    }

    //Updating existing non-primary contact to primary contact
    @isTest
    private static void testUpdateWithNoPrimaryContact() {
        //Initialize
        initData('testUpdateWithNoPrimaryContact');

        //Start test
        Test.startTest();
        //Test
		testNonPrimaryCon.Is_Primary_Contact__c = true;
        update testNonPrimaryCon;
        //Stop Test
        Test.stopTest();

        //Retrieve data for assertion
        Contact assertCon = [SELECT Id, LastName, Primary_Contact_Phone__c
                             FROM Contact 
                             WHERE LastName = 'TestCont3'
                             AND AccountId = :accWithNoPrimary.Id];
        
        //Assertions
        System.assertEquals('345-8439', assertCon.Primary_Contact_Phone__c);
    }

    // To show if primary contact already exists
    // can't insert a primary contact
    @isTest
    private static void testInsertWithPrimaryContact() {
        //Initialize
        initData('testInsertWithPrimaryContact');
        
        Contact failCon = new Contact(LastName = 'FailingInsert', Is_Primary_Contact__c = true, AccountId = accWithPrimaryInsert.Id);

        //Start test
        Test.startTest();
        //Test
        Database.SaveResult result = Database.insert(failCon, false);

        //Stop Test
		Test.stopTest();
        
        //Assertions
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Account Already Has A Primary Contact.',
                             result.getErrors()[0].getMessage());
    }

    //If Account doesn't have a primary contact set, new inserted primary contact
    //sets the rest of the contact's primary contact phone
    @isTest
    private static void testInsertWithNoPrimaryContact() {
        //Initialize
        initData('testInsertWithNoPrimaryContact');
        
        //Start test
        Test.startTest();
        //Test
        Contact newInsert = new Contact(LastName= 'Inserted', Phone = '333-777', Is_Primary_Contact__c = true, AccountId = accWithNoPrimaryInsert.Id);
        insert newInsert;
        //Stop Test
        Test.stopTest();
        //Retrieve data for assertion
        Contact assertCon = [SELECT Id, LastName, Primary_Contact_Phone__c
                             FROM Contact 
                             WHERE LastName = 'TestCont3'
                             AND AccountId = :accWithNoPrimaryInsert.Id];
        //Assertions
        System.assertEquals('333-777', assertCon.Primary_Contact_Phone__c); 
        
    }

    //Test to see updating one Account's primary contact doesn't effect other accounts
    @isTest
    private static void testForMultipleAccounts() {
        //Initialize
        initData('testForMultipleAccounts');
        
        //Start test
        Test.startTest();
        //Test
        conOne.Phone = '000';
        update conOne;
        conTwo.Phone = '111';
        update ConTwo;
        //Stop Test
        Test.stopTest();
        
        //Retrieve data for assertion
        Contact conAccOne = [SELECT Id, LastName, Primary_Contact_Phone__c
                             FROM Contact 
                             WHERE LastName = 'TestCont1'
                             AND AccountId = :accOne.Id];
        Contact conAccTwo = [SELECT Id, LastName, Primary_Contact_Phone__c
                             FROM Contact 
                             WHERE LastName = 'TestCont5'
                             AND AccountId = :accTwo.Id];
        //Assertions
        System.assertEquals('000', conAccOne.Primary_Contact_Phone__c);
        System.assertEquals('111', conAccTwo.Primary_Contact_Phone__c);

    }
    
    //To test ContactTriggerHandlers future method
    @isTest
    private static void testUpdatePrimaryContactPhone() {
        //Initialize
        initData('testUpdatePrimaryContactPhone');
        
        //Create a map of primary contact phone to pass in to future method
        Map<Id, String> primaryContactPhone = new Map<Id, String>();
        for(Contact con :contsListForFuture) {
            if(con.Is_Primary_Contact__c) {
                primaryContactPhone.put(con.AccountId, con.Phone);
              }
         }
        //Start Test
        Test.startTest();
        //test
        ContactTriggerHandler.updatePrimaryContactPhone(primaryContactPhone);
        //Stop test
        Test.stopTest();
        //Retrieve data for assertion
        Contact conFuture = [SELECT Id, LastName, Primary_Contact_Phone__c
                             FROM Contact 
                             WHERE LastName = 'TestCont8'
                             AND AccountId = :accForFuture.Id];
        
        //Assertion
        System.assertEquals('590', conFuture.Primary_Contact_Phone__c);     
        
    }
   
}