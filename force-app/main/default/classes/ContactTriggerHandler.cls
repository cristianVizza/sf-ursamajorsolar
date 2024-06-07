/**
 * @description       : 
 * @author            : Cristian Vizzarri
 * @group             : 
 * @last modified on  : 06-03-2024
 * @last modified by  : Cristian Vizzarri
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   06-03-2024   Cristian Vizzarri   Initial Version
**/
public with sharing class ContactTriggerHandler {
    
    public static void validateChanges(List<Contact> newContactList, Map<Id,Contact> oldContactMap){
        for(Contact con : newContactList){
            Contact oldContactRecord = oldContactMap != null && oldContactMap.containsKey(con.Id) ? oldContactMap.get(con.Id) : null;
            if(oldContactMap != null && oldContactRecord.OtherPhone != con.OtherPhone || oldContactMap == null && con.OtherPhone != null){
                con.addError('OtherPhone', 'OtherPhone cant by changed for this user');
            }
        }
    }

    public static void updateRelatedAccount(List<Contact> newContactList, Map<Id,Contact> oldContactMap){
        Set<Id> relatedAccIdsSet = new Set<Id>();
        List<Account> accToUpdateList = new List<Account>();

        for(Contact con : newContactList){
            relatedAccIdsSet.add(con.AccountId);
        }

        for(Account acc : [SELECT Id, Name FROM Account WHERE Id IN :relatedAccIdsSet]){
            accToUpdateList.add(new Account(Id = acc.Id, Type = 'Other'));
        }

        update accToUpdateList;
    }
}