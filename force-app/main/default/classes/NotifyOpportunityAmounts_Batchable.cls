/*************************************************************************************
 * @Name         : NotifyOpportunityAmounts_Batchable.cls
 * @Description  : Apex Batch Class To Notify PrimaryContact on Opportunity
 * @Created By   : Cem
 * @Created Date : 20.09.2021
 *************************************************************************************/


public class NotifyOpportunityAmounts_Batchable implements Database.Batchable<sObject>, Database.Stateful {
    
    public Integer recordsProcessed = 0;

    //Map of AccountIds to  opportunities
    Map<Id, Map<String, Double>> accOppStageAmount = new Map<Id, Map<String,Double>>();
    //Query to obtain Opportunities
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, AccountId, LastModifiedDate, CreatedDate, Amount, StageName 
                                         FROM Opportunity WHERE StageName IN ('Closed Won', 'Closed Lost', 'Open') 
                                         AND (LastModifiedDate >= This_Month OR CreatedDate >= This_Month)]);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        // Map of opportunities' stagename to amount 
        Map<String, Double> oppStageAmount = new Map<String, Double>();
        for(Opportunity oppty :scope) {
            oppStageAmount.put(oppty.StageName, oppty.Amount);
            //Adding new map to bigger map
            accOppStageAmount.put(oppty.AccountId, oppStageAmount);
            recordsProcessed = recordsProcessed + 1;
        }
            
    }
    
    public void finish(Database.BatchableContext bc) {
 
        System.debug('recordsProcessed: ' + recordsProcessed);
        //Constructing mail properties
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        List<String> sendTo = new List<String>();
        
        //Getting related primary contacts
        List<Contact> primaryContacts = new List<Contact>();
        try {
            primaryContacts = [SELECT Id, LastName, Is_Primary_Contact__c, Email, AccountId, Account.Name 
                                         FROM Contact WHERE Is_Primary_Contact__c = true 
                                         AND AccountId IN :accOppStageAmount.keySet()];
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }

   
        System.debug('primaryContacts: ' + primaryContacts);
        //Foreach primary contact send email
        for(Contact con :primaryContacts){
            
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            mail.setSenderDisplayName('My Org');
            mail.setSubject('Current Opportunities');
            String table = '';
            String body = '';
            
            //Start table
            table = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
            for(String opp :accOppStageAmount.get(con.AccountId).keySet()){
                table += '<tr><td>' + con.Account.Name + '</td><td>' + opp + '</td><td>' + accOppStageAmount.get(con.AccountId).get(opp) + '</td></tr>';
                
            }
            table += '</table>'; 
            // Set up html body-add table for email
            body += '<html><body>' + 'Below is a table of opportunities related to account :' + con.Account.Name + '<br><br>' + 
                table + '<br><br>' + '</body></html>';
             mail.setHtmlBody(body);
             //collect every mail
             mailsToSend.add(mail);
        }
        //Send email
        //Messaging.sendEmail(mailsToSend);
 
        System.debug('Mails Sent:' + mailsToSend);
    }

}