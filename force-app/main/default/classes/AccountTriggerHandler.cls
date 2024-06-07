/**
 * @description       : 
 * @author            : Cristian Vizzarri
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : Cristian Vizzarri
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   05-30-2024   Cristian Vizzarri   Initial Version
**/
public with sharing class AccountTriggerHandler {
    
    public static void validateDescription(List<Account> newAccountList, Map<Id,Account> oldAccountMap){
        for(Account acc : newAccountList){
            Account oldAccountRecord = oldAccountMap != null && oldAccountMap.containsKey(acc.Id) ? oldAccountMap.get(acc.Id) : null;
            if(oldAccountRecord != null && acc.Description != oldAccountRecord.Description || oldAccountMap == null && acc.Description != null){
                acc.addError('Description', 'Description cannot be changed by this user');
            }
        }
    }
}