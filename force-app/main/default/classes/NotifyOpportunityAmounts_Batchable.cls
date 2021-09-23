/*************************************************************************************
 * @Name         : NotifyOpportunityAmounts_Batchable.cls
 * @Description  : Apex Batch Class To Notify PrimaryContact on Opportunity
 * @Created By   : Cem
 * @Created Date : 20.09.2021
 *************************************************************************************/


public class NotifyOpportunityAmounts_Batchable implements Database.Batchable<sObject>, Database.Stateful {

    private static final Set<String> STAGENAMES_TO_PROCESS = new Set<String>{'Closed Won', 'Closed Lost', 'Open'};

    //Map of AccountIds to  opportunities
    Map<Id, Map<String, Double>> opportunityStageAndAmountPerAccount = new Map<Id, Map<String,Double>>();
    //Map to use in test class
    @TestVisible
    private static Map<Id, Map<String, Double>> mapForTest = new Map<Id, Map<String,Double>>();
    //Query to obtain Opportunities
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, AccountId, LastModifiedDate, CreatedDate, Amount, StageName 
                                         FROM Opportunity WHERE StageName IN :STAGENAMES_TO_PROCESS 
                                         AND (LastModifiedDate >= This_Month OR CreatedDate >= This_Month)]);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for(Opportunity opportunityRecord : scope) {
            //Fetch opportunity amounts 
            Map<String, Decimal> opportunityAmountForEachStage = new Map<String, Decimal>();
            //If it is already added
            if(this.opportunityStageAndAmountPerAccount.containsKey(opportunityRecord.AccountId)) {
                opportunityAmountForEachStage = this.opportunityStageAndAmountPerAccount.get(opportunityRecord.AccountId);
            }
            //If account has more than one opportunity with same stage name get total
            Decimal amount = opportunityRecord.Amount;
            if(opportunityAmountForEachStage.containsKey(opportunityRecord.StageName)) {
                amount = opportunityAmountForEachStage.get(opportunityRecord.StageName) + amount;
            }
            opportunityAmountForEachStage.put(opportunityRecord.StageName, amount);
            this.opportunityStageAndAmountPerAccount.put(opportunityRecord.AccountId, opportunityAmountForEachStage);
        }
		
    }
    
    public void finish(Database.BatchableContext bc) {
 
        //Constructing mail properties
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        List<String> sendTo = new List<String>();
        
        //Getting related primary contacts
        List<Contact> primaryContacts = new List<Contact>();
        try {
            primaryContacts = [SELECT Id, LastName, Is_Primary_Contact__c, Email, AccountId, Account.Name 
                                         FROM Contact WHERE Is_Primary_Contact__c = true 
                                         AND AccountId IN :this.opportunityStageAndAmountPerAccount.keySet()];
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }

   
        System.debug('primaryContacts: ' + primaryContacts);
        //Foreach primary contact send email
        for(Contact primaryContact :primaryContacts){
            
            sendTo.add(primaryContact.Email);
            mail.setToAddresses(sendTo);
            mail.setSenderDisplayName('My Org');
            mail.setSubject('Current Opportunities');
            String table = '';
            String body = '';
            
            //Start table
            table = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
            for(String opportunityStageName :this.opportunityStageAndAmountPerAccount.get(primaryContact.AccountId).keySet()){
                table += '<tr><td>' + primaryContact.Account.Name + '</td><td>' + opportunityStageName + '</td><td>' + this.opportunityStageAndAmountPerAccount.get(primaryContact.AccountId).get(opportunityStageName) + '</td></tr>';
                
            }
            table += '</table>'; 
            // Set up html body-add table for email
            body += '<html><body>' + 'Below is a table of opportunities related to account :' + primaryContact.Account.Name + '<br><br>' + 
                table + '<br><br>' + '</body></html>';
             mail.setHtmlBody(body);
             //collect every mail
             mailsToSend.add(mail);
        }
        //Send email
        //Messaging.sendEmail(mailsToSend);
        
 		mapForTest = this.opportunityStageAndAmountPerAccount;
        System.debug('Mails Sent:' + mailsToSend);
    }

}