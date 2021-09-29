/*************************************************************************************
 * @Name         : TestWeatherRest.cls
 * @Description  : Test class for WeatherRestController
 * @Created By   : Cem
 * @Created Date : 28.09.2021
 *************************************************************************************/
@isTest
public class TestWeatherRest {
    private static Account refAcct;
    private static Account badResponseAcc;
    
    private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'testResponse' {
                
                 //Dummy Account for test
                Account acct = new Account();
                acct.Name = 'TestAccount';
                acct.BillingCity = 'London';
                insert acct;
                
                refAcct = acct;
                              
            }
            when 'testBadResponse' {
                //dummy account for test
                Account badResAct = new Account(Name = 'BadAcc', BillingCity = 'Lawrence');
                insert badResAct;
                badResponseAcc = badResAct;

            }
        }
    }
    //Test successfull response
    @isTest
    private static void testResponse() {
        //initialize
        initData('testResponse');
  
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new WeatherRestCalloutMock_HttpCalloutMock());
        //create a standard controller and pass the dummy account controller 
        ApexPages.StandardController accountController = new ApexPages.StandardController(refAcct);
        //Get the Standard Controller and pass it to controller extension
        WeatherRestController ext = new WeatherRestController(accountController);
        //start test
        Test.startTest();
        //test
        ext.getValues();
        //Stop test
        Test.stopTest();

        //Assert mock response values
        System.assertEquals('London', ext.wrapper.name);
        System.assertEquals(28, ext.wrapper.main.temp);
        System.assertEquals('clear sky', ext.wrapper.weather[0].description);
        System.assertEquals('01d', ext.wrapper.weather[0].icon);
    }

    //Test bad request
    @isTest
    private static void testBadResponse() {
        initData('testBadResponse');

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new WeatherRestBadRequest_HttpCalloutMock());
        //create a standard controller and pass the dummy account controller
        ApexPages.StandardController accountController = new ApexPages.StandardController(badResponseAcc);
        //Get the Standard Controller and pass it to controller extension
        WeatherRestController ext = new WeatherRestController(accountController);

        Exception expectedException;
        //start test
        Test.startTest();
        //test
        try {
            ext.getValues();
            String city = ext.wrapper.name;
            Double temperature = ext.wrapper.main.temp;
            String description = ext.wrapper.weather[0].description;
            String icon = ext.wrapper.weather[0].icon;
        } catch(Exception ex) {
            expectedException = ex;
        }        
        //Stop test
        Test.stopTest();

        //Assert values are null
        System.assertNotEquals(null, expectedException);
        System.assertEquals('Attempt to de-reference a null object', expectedException.getMessage());

    }

}