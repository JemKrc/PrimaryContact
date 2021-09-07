/*************************************************************************************
 * @Name         : PrimaryContactController.cls
 * @Description  : Apex class for PrimaryContact page
 * @Created By   : Cem
 * @Created Date : 07.09.2021
 *************************************************************************************/
public class PrimaryContactController {
    
    public List<contact> contacts {get;set;}
    
    public String searchText {
        get {
            if(searchText == null) {
                searchText = ''; 
            }
            return searchText;
        }
        set;
    }
    public Id primaryContactId {get;set;}

    @TestVisible
    private Account accountRecord;

    //Constructing extension controller for standard account controller
    public PrimaryContactController(ApexPages.StandardController stdCont) {
        this.accountRecord = (Account)stdCont.getRecord();
        this.getRelatedContacts();
        
    }
    
    
    public void getRelatedContacts() {
        this.contacts = new List<Contact>();
        String formattedSearch = '%'+this.searchText+'%';
        try {
            this.contacts  = [SELECT id, LastName, Title, Phone, Is_Primary_Contact__c 
                FROM Contact 
                WHERE accountid = :this.accountRecord.id 
                AND Name LIKE :formattedSearch
                ORDER BY LastName 
                LIMIT 990];
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            //use apex page messages to show something like "An error happened, please check your logs"
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Test'));
        }
    }

    
    public void setPrimary() {
        if(this.primaryContactId != NULL) {
            //Getting the rest of the contacts that are not primary
            try {
                List<Contact> allRelatedContacts = [SELECT Id 
                    FROM Contact 
                    WHERE AccountId = :this.accountRecord.Id];
                for(Contact relatedContact: allRelatedContacts) {

                    relatedContact.Is_Primary_Contact__c = (this.primaryContactId == relatedContact.Id);
                }
                
                update allRelatedContacts;
                this.getRelatedContacts();
            } catch(Exception ex) {
                System.debug(ex.getMessage());
                 //use apex page messages to show something like "An error happened, please check your logs"
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Failed to set contact as primary!'));
            }
        }
        
    }
}