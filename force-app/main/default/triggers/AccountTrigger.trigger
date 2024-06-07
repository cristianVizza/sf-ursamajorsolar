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
trigger AccountTrigger on Account (before insert, before update) {

    Boolean globalByPass = FeatureManagement.checkPermission('CV_Global_Automation_Validation_ByPass');
    Boolean accountObjectByPass = FeatureManagement.checkPermission('CV_Account_Automation_Validation_ByPass');
    System.debug('globalByPass: ' + globalByPass);
    System.debug('accountObjectByPass: ' + accountObjectByPass);

    if(globalByPass || accountObjectByPass){
        return;
    }

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountTriggerHandler.validateDescription((List<Account>) Trigger.new, null);
        }
        if(Trigger.isUpdate){
            AccountTriggerHandler.validateDescription((List<Account>) Trigger.new, (Map<Id,Account>)Trigger.oldMap);
        }
    }
}