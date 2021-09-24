@isTest
public class TestOpportunitySummary_Schedulable {
    //field for daily schedule
    private static String dailyJobCron;
    //field for weekly schedule
    private static String weeklyJobCron;
    //field for monthly schedule
    private static String monthlyJobCron;
    
    private static void initData(String actionToDo) {
        switch on actionToDo {
            when 'testDailySchedule' {
                //Setting test cron expression
                String dailyTenAm = '0 0 10 * * ?';                               
                dailyJobCron = dailyTenAm;
         
            }
            when 'testWeeklySchedule' {
                //setting test cron expression
                String everyFriOnePm = '0 0 13 ? * 6';
                weeklyJobCron = everyFriOnePm;
            }
            when 'testMonthlySchedule' {
                //setting test cron expression
                String lastFriEveryMonth = '0 0 18 ? * 6L';
                monthlyJobCron = lastFriEveryMonth;
            }
        }
    }
    
    //Test schedule that fires everyday at 10 a.m.
    @isTest
    private static void testDailySchedule() {
        //initialize
        initData('testDailySchedule');
        
        //Start test
        Test.startTest();
        //test
        String dailyJobId = System.schedule('Daily Job', dailyJobCron, new OpportunitySummary_Schedulable());
        CronTrigger dailyTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                 FROM CronTrigger WHERE id = :dailyJobId];
        //Stop test
        Test.stopTest();
        
        //Assert cron expression is correct
        System.assertEquals(dailyJobCron, dailyTrig.CronExpression);
        //Assert haven't started working yet
        System.assertEquals(0, dailyTrig.TimesTriggered);
        //Assert next fire of schedular
        System.assertEquals('2021-09-23 10:00:00', String.valueOf(dailyTrig.NextFireTime));
    }
    @isTest
    private static void testWeeklySchedule() {
        //initialize
        initData('testWeeklySchedule');
        
        //Start test
        Test.startTest();
        //test
        String weeklyJobId = System.schedule('Weekly Job', weeklyJobCron, new OpportunitySummary_Schedulable());
        CronTrigger weeklyTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                 FROM CronTrigger WHERE id = :weeklyJobId];
        //Stop test
        Test.stopTest();
        
        //Assert cron expression is correct
        System.assertEquals(weeklyJobCron, weeklyTrig.CronExpression);
        //Assert haven't started working yet
        System.assertEquals(0, weeklyTrig.TimesTriggered);
        //Assert next fire of schedular
        System.assertEquals('2021-09-24 13:00:00', String.valueOf(weeklyTrig.NextFireTime));
    }
    
    @isTest
    private static void testMonthlySchedule() {
         //initialize
        initData('testMonthlySchedule');
        
        //Start test
        Test.startTest();
        //test
        String monthlyJobId = System.schedule('Monthly Job', monthlyJobCron, new OpportunitySummary_Schedulable());
        CronTrigger monthlyTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                 FROM CronTrigger WHERE id = :monthlyJobId];
        //Stop test
        Test.stopTest();
        
        //Assert cron expression is correct
        System.assertEquals(monthlyJobCron, monthlyTrig.CronExpression);
        //Assert haven't started working yet
        System.assertEquals(0, monthlyTrig.TimesTriggered);
        //Assert next fire of schedular
        System.assertEquals('2021-09-24 18:00:00', String.valueOf(monthlyTrig.NextFireTime));
    }

}