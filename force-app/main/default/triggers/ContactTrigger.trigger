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
trigger ContactTrigger on contact (before insert, before update, after insert, after update) {

    List<Contact> newContactList = (List<Contact>)Trigger.new;
    Map<Id,Contact> oldContactMap = (Map<Id,Contact>)Trigger.oldMap;
    SObjectType triggerType = Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType();
    String objectTriggerName = triggerType.getDescribe().getLabel(); //Object triggered name
    CV_Automation_Bypass_control__mdt globalBypass = CV_Automation_Bypass_control__mdt.getInstance('Global_Bypass');
    CV_Automation_Bypass_control__mdt contactByPass = CV_Automation_Bypass_control__mdt.getInstance(objectTriggerName);

    System.debug('contactByPass.bypassBefore__c: ' + objectTriggerName + ' --' + contactByPass.isActive__c);
    System.debug('contactByPass.bypassBefore__c: ' + objectTriggerName + ' --' + contactByPass.bypassBefore__c);
    

    //check for global bypass or for object
    if(globalBypass.isActive__c || contactByPass.isActive__c) {return;}

   
    //check for 
    if (Trigger.isBefore && !contactByPass.bypassBefore__c) {        
        if(Trigger.isInsert){
            ContactTriggerHandler.validateChanges(newContactList,null);
        }
        if(Trigger.isUpdate){
            ContactTriggerHandler.validateChanges(newContactList, oldContactMap);
        }
    }

    if(Trigger.isAfter && !contactByPass.bypassAfter__c){
        if(Trigger.isInsert){

        }
        if(Trigger.isUpdate){
            ContactTriggerHandler.updateRelatedAccount(newContactList, oldContactMap);
        }
    }
}