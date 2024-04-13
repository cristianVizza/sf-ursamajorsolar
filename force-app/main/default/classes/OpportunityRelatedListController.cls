/**
 * @description       : 
 * @author            : Cristian Vizzarri
 * @group             : 
 * @last modified on  : 12-11-2023
 * @last modified by  : Cristian Vizzarri
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   12-07-2023   Cristian Vizzarri   Initial Version
**/

public class OpportunityRelatedListController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getRelatedRecords() {
        return [SELECT Id, Name, Account.Name, AccountId, Amount, CloseDate, StageName, Description, Pricebook2.Name FROM Opportunity ORDER BY Name ASC];
    }
    
    @AuraEnabled
    public static void saveDraftValues(Object data) {
        List<Opportunity> listOfOpportunities = (List<Opportunity>) JSON.deserialize(
            JSON.serialize(data),
            List<Opportunity>.class
        );
        System.debug(LoggingLevel.DEBUG, 'listOfOpportunities: ' + listOfOpportunities);
        update listOfOpportunities;
    }

    @AuraEnabled
    public static void processSelectedOpportunities(List<Opportunity> selectedOpportunities) {
        // Implement your custom logic to process selected opportunities on the server side.
        // You can use the selectedOpportunities parameter to access the selected records.
        // For example: update selectedOpportunities;
    }
    
}