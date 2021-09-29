/*************************************************************************************
 * @Name         : WeatherRestWrapper.cls
 * @Description  : Wrapper Class For Deserialize JSON 
 * @Created By   : Cem
 * @Created Date : 24.09.2021
 *************************************************************************************/

public class WeatherRestWrapper {
    public class Weather {
        public String description {get;set;}
        public String icon {get;set;}
    }
    
    public class Main {
        public Double temp {get;set;}
        
    }
    
    public List<Weather> weather {get;set;}
    public Main main {get;set;}
    public String name {get;set;}
    
}