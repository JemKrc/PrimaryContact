public class ContactTriggerHandler {

    public static void handleBeforeUpdate (List<Contact> contacts) {

    Set<Id> accountIds = new Set<Id>();
    //select ALL needed account Ids
    for(Contact newContact : contacts) {
        accountIds.add(newContact.AccountId);
    }
    
    //we select ALL primary contacts of previously selected account ids
    List<Contact> allPrimaryContacts = [SELECT Id, Is_Primary_Contact__c, AccountId  
        FROM Contact 
        WHERE Is_Primary_Contact__c = true 
        AND AccountId IN :accountIds ];
    
   
    Map<Id, Contact> primaryContactPerAccount = new Map<Id, Contact>();
    Map<Id, String> primaryContactPhonePerAccount = new Map<Id, String>();
    //we build a map of account id to contact id
    for(Contact existingPrimaryContact : allPrimaryContacts) { 
        primaryContactPerAccount.put(existingPrimaryContact.AccountId, existingPrimaryContact);
    }

    for(Contact newContact : contacts) {
        //process only primary ones
        if(newContact.Is_Primary_Contact__c) {
            primaryContactPhonePerAccount.put(newContact.AccountId, newContact.Phone);
            //we check if MAP contains a key with our contacts account id
            if(primaryContactPerAccount.containsKey(newContact.AccountId)) {
                //we check if primary contact for account of our current contact is the same contact or not
                if(newContact.Id != primaryContactPerAccount.get(newContact.AccountId).Id) {
                    newContact.addError('Account already has a Primary Contact');
                }
            } 
        }
     }
     if(primaryContactPhonePerAccount.size() > 0) {
        updatePrimaryContactPhone_Future(primaryContactPhonePerAccount);
     }
     


}
    @future
    public static void updatePrimaryContactPhone_Future(Map<Id, String> primaryContactPhone) {

        //Get all the contacts that are not primary
        List<Contact> nonPrimaryContacts = [SELECT Id, Is_Primary_Contact__c, Primary_Contact_Phone__c, AccountId 
                                            FROM Contact
                                            WHERE AccountId IN :primaryContactPhone.keySet()
                                            AND Is_Primary_Contact__c = false];

        //Set all non-primary contacts Primary Contact Phone    
        for(Contact nonPrimary : nonPrimaryContacts){
            nonPrimary.Primary_Contact_Phone__c = primaryContactPhone.get(nonPrimary.AccountId);
        }

        System.debug('nonPrimaryContacts' + nonPrimaryContacts);
        update nonPrimaryContacts;

    }

    public static void handleBeforeInsert(List<Contact> insertedContacts) { 
    
    Set<Id> accountIds = new Set<Id>();

    //select ALL needed account Ids
    for(Contact newContact : insertedContacts) {
        accountIds.add(newContact.AccountId);
    }

    Map<Id, Contact> primaryContactPerAccount = new Map<Id, Contact>();
    Map<Id, String> primaryContactPhonePerAccount = new Map<Id, String>();
    //we select ALL primary contacts of previously selected account ids
    List<Contact> allPrimaryContacts = [SELECT Id, Is_Primary_Contact__c, AccountId  
                                        FROM Contact 
                                        WHERE Is_Primary_Contact__c = true 
                                        AND AccountId IN :accountIds ];
    
    //we build a map of account id to contact id
    for(Contact existingPrimaryContact : allPrimaryContacts) {
        primaryContactPerAccount.put(existingPrimaryContact.AccountId, existingPrimaryContact);
    }

    for(Contact insertedContact : insertedContacts){
        if(insertedContact.Is_Primary_Contact__c){
            if(primaryContactPerAccount.get(insertedContact.AccountId) != null) {
                insertedContact.addError('Account Has A Primary Contact.');
            } else{
                primaryContactPhonePerAccount.put(insertedContact.AccountId, insertedContact.Phone);
            }
        }
    }

    if(primaryContactPhonePerAccount.Size() > 0){
        updatePrimaryContactPhone_Future(primaryContactPhonePerAccount);
    }

    }
}

