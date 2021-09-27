/*************************************************************************************
 * @Name         : WeatherRestController.cls
 * @Description  : Apex class for WeatherRest page
 * @Created By   : Cem
 * @Created Date : 24.09.2021
 *************************************************************************************/

public class WeatherRestController {
    public static final String CALLOUT_FAIL_MESSAGE = 'There was an Error.';
    public static final String ACCOUNT_NOT_FOUND = 'Account Not Found.';
    public static final String API_KEY = '&APPID=41486adbb708505907127a781ff38782';
    public static final String END_POINT = 'http://api.openweathermap.org/data/2.5/weather?q=';
    public static final String TEMP_UNIT = '&units=metric';
    
    public String city {get; set;}
    public String description {get; set;}
    public String temperature {get; set;}
    public String icon {get;set;}
    private Account accountRecord;
    public WeatherRestWrapper wrapper;
    
    //Constructor
    public WeatherRestController (ApexPages.StandardController stdController) {
        this.accountRecord = (Account)stdController.getRecord();
    }
    
    //Retrieve values from call-out
    public void getValues() {
        //Get account
        Account account = new Account();
        try {
            account = [SELECT Id, BillingCity FROM Account WHERE Id =:this.accountRecord.Id];
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        } 
        
        if(Account.Id != null) {
  
        //Set endpoint params
        String accountCity = account.BillingCity;
        String requestEndpoint = END_POINT + accountCity + TEMP_UNIT + API_KEY;

        //Make the call
        Http http = new Http();
		HttpRequest request = new HttpRequest();
            
        try { 
        	request.setEndpoint(requestEndpoint);
			request.setMethod('GET');
        	request.setTimeout(20000);
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
		
        HttpResponse response = new HttpResponse();
        
        try {
            response = http.send(request);
        } catch(System.CalloutException ex) {
            System.debug(ex.getMessage());
        }
		
     
        if (response.getStatusCode() == 200) {
            //Get response onto Wrapper instance
            this.wrapper = (WeatherRestWrapper)Json.deserialize(response.getBody(), WeatherRestWrapper.class);
            //Set values
            this.city = wrapper.name;
            this.temperature = String.valueOf(wrapper.main.temp);
            this.description = wrapper.weather[0].description;
            this.icon = wrapper.weather[0].icon;
         
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CALLOUT_FAIL_MESSAGE));
        }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ACCOUNT_NOT_FOUND));
        }
   }
}