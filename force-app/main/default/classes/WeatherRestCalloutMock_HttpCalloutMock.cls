/*************************************************************************************
 * @Name         : TestWeatherRestCalloutMock_HttpCalloutMock.cls
 * @Description  : Test class for TestWeatherRest
 * @Created By   : Cem
 * @Created Date : 28.09.2021
 *************************************************************************************/
@isTest
global class WeatherRestCalloutMock_HttpCalloutMock implements HttpCalloutMock {
     // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setBody('{"weather": [{"main":"Clear", "description":"clear sky", "icon":"01d"}],"main":{"temp": 28}, "name":"London"}');
        response.setStatusCode(200);
        return response; 
    }

}