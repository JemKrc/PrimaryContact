/*************************************************************************************
 * @Name         : ContactTriggerHandler.cls
 * @Description  : Apex class for Handling Trigger on Contact
 * @Created By   : Cem
 * @Created Date : 15.09.2021
 *************************************************************************************/

public class ContactTriggerHandler {

    public static void handleBeforeUpdateInsert(List<Contact> contacts, Map<Id, Contact> oldContacts) {

    Set<Id> accountIds = new Set<Id>();

    //select ALL needed account Ids
    for(Contact newContact : contacts) {
        accountIds.add(newContact.AccountId);
    }
    
    List<Contact> allPrimaryContacts = new List<Contact>();
    try {
        //we select ALL primary contacts of previously selected account ids
        allPrimaryContacts = [SELECT Id, Is_Primary_Contact__c, AccountId 
                                            FROM Contact 
                                            WHERE Is_Primary_Contact__c = true 
                                            AND AccountId IN :accountIds ];
    } catch(Exception ex) {
        System.debug(ex.getMessage());
    }
      
    Map<Id, Contact> primaryContactPerAccount = new Map<Id, Contact>();
    Map<Id, String> primaryContactPhonePerAccount = new Map<Id, String>();

    //we build a map of account id to contact id
    for(Contact existingPrimaryContact : allPrimaryContacts) { 
        primaryContactPerAccount.put(existingPrimaryContact.AccountId, existingPrimaryContact);
    }

    for(Contact newContact : contacts) {
        //process only primary ones
        if(newContact.Is_Primary_Contact__c && primaryContactPerAccount.size() > 0) {
            //we check if MAP contains a key with our contacts account id
            if(primaryContactPerAccount.containsKey(newContact.AccountId)) {
                //we check if primary contact for account of our current contact is the same contact or not
                if(newContact.Id != primaryContactPerAccount.get(newContact.AccountId).Id) {
                    newContact.addError('Account already has a Primary Contact');
                } 
                if(newContact.Id == primaryContactPerAccount.get(newContact.AccountId).Id 
                   && newContact.Phone != oldContacts.get(newContact.Id).Phone) {
                       primaryContactPhonePerAccount.put(newContact.AccountId, newContact.Phone);
                   }
            } 
        }

        // If primary contact is not assigned allow only one primary contact to be updated or inserted
        if(newContact.Is_Primary_Contact__c && primaryContactPerAccount.size() == 0) {
            if(primaryContactPhonePerAccount.size() > 0) {
                newContact.addError('Cant update or insert more than one primary contact');
            } else {
                primaryContactPhonePerAccount.put(newContact.AccountId, newContact.Phone);
            } 
            
                    
       }
     }

     //To avoid duplication
     if(primaryContactPhonePerAccount.size() > 0) {
        updatePrimaryContactPhone_Future(primaryContactPhonePerAccount);
     }

}

    //Async primary contact phone update
    @future
    public static void updatePrimaryContactPhone_Future(Map<Id, String> primaryContactPhone) {

        try { 
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
            
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }

}

