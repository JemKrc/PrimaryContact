/*************************************************************************************
 * @Name         : NotifyOpportunityAmounts_Batchable.cls
 * @Description  : Apex Batch Class To Notify PrimaryContact on Opportunity
 * @Created By   : Cem
 * @Created Date : 20.09.2021
 *************************************************************************************/


public class NotifyOpportunityAmounts_Batchable implements Database.Batchable<sObject> {

    //Map of primary contacts to account opportunities
    Map<Contact, Map<String, Double>> contOppStageAmount = new Map<Contact, Map<String,Double>>();
    //Query to obtain accounts with primary contact, related primary contacts
    //and related opportunities
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name,
                                       (SELECT Id, Name, LastName, Is_Primary_Contact__c
                                        FROM Contacts WHERE Is_Primary_Contact__c = true),
                                       (SELECT Id, Name, Amount, StageName FROM Opportunities) FROM Account
                                       	WHERE Id IN 
                                       (SELECT AccountId 
                                        FROM Contact 
                                        WHERE Is_Primary_Contact__c = true)]);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // Map of opportunities' stagename to amount of each account
        Map<String, Double> oppStageAmount = new Map<String, Double>();
        for(Account acc :scope) {
            for(Opportunity oppty :acc.Opportunities) {
                oppStageAmount.put(oppty.StageName, oppty.Amount);
            }
            //Adding opportunity map to primary contact 
            contOppStageAmount.put(acc.contacts, oppStageAmount);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // set up email proprerties
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();

        //for each primary contact construct email
        for(Contact con :contOppStageAmount.keySet()){
            
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            mail.setSenderDisplayName('My Org');
            mail.setSubject('Current Opportunities');
            String table = '';
            String body = '';
            
            //Set up html table for email - foreach opportunity stage name
            table = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
            for(String opp :contOppStageAmount.get(con).keySet()){
                table += '<tr><td>' + con.Account.Name + '</td><td>' + opp + '</td><td>' + contOppStageAmount.get(con).get(opp) + '</td></tr>';
                
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
        Messaging.sendEmail(mailsToSend);
        
    }

}