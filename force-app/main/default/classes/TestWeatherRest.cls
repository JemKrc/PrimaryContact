/*************************************************************************************
 * @Name         : TestWeatherRest.cls
 * @Description  : Test class for WeatherRestController
 * @Created By   : Cem
 * @Created Date : 28.09.2021
 *************************************************************************************/
@isTest
public class TestWeatherRest {
    private static Account refAcct;
    
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
        }
    }
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

}