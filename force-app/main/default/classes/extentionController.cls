public class PrimaryContactController {
    
private Account acct;
public List<contact> extContacts{get;set;}
public String searchText{get
    {if(searchText == null) searchText = ''; return searchText;}
        set;}

	//Constructing extension controller for standard account controller
    public PrimaryContactController(ApexPages.StandardController stdCont){
        this.acct = (Account)stdCont.getRecord();
        this.extContacts = setExtensionContact();
       
    }

    //Method to use populate contacts in constructor and in search method
    public List<Contact> setExtensionContact(){
        List<Contact> setContactList = new List<Contact>();
        try {
           setContactList  = [SELECT id, LastName, Title, Phone, Is_Primary_Contact__c FROM contact WHERE accountid = :this.acct.id ORDER BY LastName LIMIT 990];
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        return setContactList;
    }
    
    public PageReference search()
    {
        if(this.extContacts == null){
            this.extContacts = new List<Contact>();
        } else{
            this.extContacts.clear();
        }
        
        //using searchText to filter 
        for(Contact con: setExtensionContact()){
            if(con.LastName.contains(this.searchText)){
                this.extContacts.add(con);
            }
        }
        
        return null;
            

    }

    public void setPrimary(){
        //Getting contactId from the page
        String contactId = Apexpages.currentpage().getParameters().get('contactId');
        
        //Setting selected contact's field
        Contact primaryContact = new Contact(Id = contactId, Is_Primary_Contact__c = true);
        
        //Getting the rest of the contacts that are not primary
        List <Contact> conts = [SELECT Id From Contact WHERE Id != :primaryContact.Id AND accountid = :this.acct.Id];
        
        //To update previously assigned primary contact to non primary
        for(Contact notPrimary: conts){
            notPrimary.Is_Primary_Contact__c = false;
        }
        
        //Combine all the contacts together
        conts.add(primaryContact);
        
        try {
        	update conts;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        } 
        
    }
}