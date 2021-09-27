/*************************************************************************************
 * @Name         : WeatherRestWrapper.cls
 * @Description  : Wrapper Class For Deserialize JSON 
 * @Created By   : Cem
 * @Created Date : 24.09.2021
 *************************************************************************************/

public class WeatherRestWrapper {
    public class Weather {
        public Integer id {get;set;}
        public String main {get;set;}
        public String description {get;set;}
        public String icon {get;set;}
    }
    
    public class Main {
        public Double temp {get;set;}
        public Double feels_like {get;set;}
        public Double temp_min {get;set;}
        public Double temp_max {get;set;}
        public Integer pressure {get;set;}
        public Integer humidity {get;set;}
        
    }
    
    public List<Weather> weather {get;set;}
    public String base {get;set;}
    public Main main {get;set;}
    public Integer id {get;set;}
    public String name {get;set;}
    
}