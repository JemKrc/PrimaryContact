/*************************************************************************************
 * @Name         : TestWeatherRestBadRequest_HttpCalloutMock.cls
 * @Description  : Test class for TestWeatherRest
 * @Created By   : Cem
 * @Created Date : 28.09.2021
 *************************************************************************************/
@isTest
global class WeatherRestBadRequest_HttpCalloutMock implements HttpCalloutMock {

     // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setBody('{"weather": [{"main":"Cloud", "description":"clear", "icon":"09n"}],"main":{"temp": 18}, "name":"Lawrence"}');
        response.setStatusCode(400);
        return response; 
    }

}