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

    //When insert will use this
    if(oldContacts == null) {
        for(Contact newInsert: contacts) {
            //if account already has a primary contact
            if(primaryContactPerAccount.containsKey(newInsert.AccountId)) {
                newInsert.addError('Account Already Has A Primary Contact.');
            } else {
                //if this is the first primary contact add it to the maps - avoids multiple inserts at once
                primaryContactPerAccount.put(newInsert.AccountId, newInsert);
                primaryContactPhonePerAccount.put(newInsert.AccountId, newInsert.Phone);
            }
        }
    }

    //if it is update will use this
    if(oldContacts != null) {
    for(Contact newContact : contacts) {
        // To see updating an existing contact
        Contact oldContact = oldContacts.get(newContact.Id);
        if(oldContact != null) {
            if(newContact.Is_Primary_Contact__c) {
                //Is there already a primary contact
                if(primaryContactPerAccount.containsKey(newContact.AccountId)) {
                    //If so is it same with our contact
                    if(newContact.Id != primaryContactPerAccount.get(newContact.AccountId).Id) {
                        newContact.addError('Account Already Has A Primary Contact.');
                    }
                    //If it is same contact we check only for the phone number change
                    if(newContact.Id == primaryContactPerAccount.get(newContact.AccountId).Id 
                    && newContact.Phone != oldContact.Phone) {
                        primaryContactPhonePerAccount.put(newContact.AccountId, newContact.Phone);
                    }
                  //If we clear primary contact first and update with this contact  
                } else {
                    primaryContactPerAccount.put(newContact.AccountId, newContact);
                    primaryContactPhonePerAccount.put(newContact.AccountId, newContact.Phone);
                }   
            }                
        } 
    
    }
}


    //To avoid duplication
     if(primaryContactPhonePerAccount.size() > 0) {
        updatePrimaryContactPhone(primaryContactPhonePerAccount);
     }
}

    //Async primary contact phone update
    @future
    public static void updatePrimaryContactPhone(Map<Id, String> primaryContactPhone) {

        try { 
            //Get all the contacts that are not primary
            List<Contact> nonPrimaryContacts = [SELECT Id, Is_Primary_Contact__c, Primary_Contact_Phone__c, AccountId 
                                                FROM Contact
                                                WHERE AccountId IN :primaryContactPhone.keySet()
                                                AND Is_Primary_Contact__c = false];

            //Set all non-primary contacts Primary Contact Phone
            for(Contact nonPrimary : nonPrimaryContacts) {
                nonPrimary.Primary_Contact_Phone__c = primaryContactPhone.get(nonPrimary.AccountId);
            }

            System.debug('nonPrimaryContacts' + nonPrimaryContacts);
            update nonPrimaryContacts;
            
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }

}