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
public with sharing class OpportunityTriggerHandler {    

    public static void validateDescription(List<Opportunity> newList, Map<Id,Opportunity> oldMap){        
        for(Opportunity o : newList){
            Opportunity opporOldItem = oldMap != null && oldMap.containsKey(o.Id) ? oldMap.get(o.Id) : null;
            if(opporOldItem != null && opporOldItem.Description != o.Description || opporOldItem == null && o.Description != null){
                o.addError('Description', 'Description cannot be changed by this user');
            }
        }
    }
}