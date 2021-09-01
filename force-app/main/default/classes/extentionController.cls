public class extentionController {
    
private Account acct;
public List<contact> extContacts{get;set;}
public Map<Integer, Contact> ContactMap {get;set;}
public String searchText{get
    {if(searchText == null) searchText = ''; return searchText;}
        set;}

	//Constructing extension controller for standard account controller
    public extentionController(ApexPages.StandardController stdCont)
    {
        this.acct = (Account)stdCont.getRecord();
        extContacts = [SELECT id, LastName, Title, Phone, Is_Primary_Contact__c FROM contact WHERE accountid = :acct.id ORDER BY LastName];
        
        //ContactMap is for displaying 2000 records by-passing limit of 1000
        ContactMap = new Map<Integer, Contact>();
        for(Integer index = 0 ; index < extContacts.size() ; index++) {
            ContactMap.put(index, extContacts[index]);
        }
    }
    
    public PageReference search()
    {
        if(ContactMap == null)
        {
            ContactMap = new Map<Integer, Contact>();
        }
        else
        {
            ContactMap.Clear();
        }
        
        //setting searchText property for query
        String contLike = '%'+searchText+'%';
        
        extContacts = [Select LastName, Title, Phone, Is_Primary_Contact__c from Contact where accountid = :acct.id AND LastName like :contLike Order By LastName];
        for(Integer index = 0 ; index < extContacts.size() ; index++) {
            ContactMap.put(index, extContacts[index]);}
        
        return null;
            

    }

    public PageReference setPrimary()
    {
        //Getting contactId from the page
        String contactId = Apexpages.currentpage().getParameters().get('contactId');
        
        //Setting selected contact's field
        Contact contact = [SELECT Id from Contact where Contact.Id = :contactId];
        contact.Is_Primary_Contact__c = true;
        
        //Getting the rest of the contacts that are not primary
        List <Contact> conts = [SELECT Id From Contact WHERE Id != :contact.Id];
        
        //To update previously assigned primary contact to non primary
        for(Contact notPrimary: conts)
        {
            notPrimary.Is_Primary_Contact__c = false;
        }
        
        //Combine all the contacts together
        conts.add(contact);
        
        try
        {
        update conts;
        }
        
        catch(Exception ex){
            System.debug(ex.getMessage());
        } 
        
        //Redirect page configuration.
        PageReference tempPage = new PageReference('/apex/PrimaryContact?id='+acct.Id);//ApexPages.currentPage();            
        tempPage.setRedirect(true);
        return tempPage;
    }
}