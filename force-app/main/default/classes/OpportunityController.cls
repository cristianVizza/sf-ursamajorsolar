/**
 * @description       : 
 * @author            : Cristian Vizzarri
 * @group             : 
 * @last modified on  : 12-11-2023
 * @last modified by  : Cristian Vizzarri
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   12-11-2023   Cristian Vizzarri   Initial Version
**/
public with sharing class OpportunityController{
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities() {
        return [SELECT Id, Name, Account.Name, Amount, CloseDate, StageName, Description FROM Opportunity];
    }
}