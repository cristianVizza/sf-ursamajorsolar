/**
 * @description       : 
 * @author            : Cristian Vizzarri
 * @group             : 
 * @last modified on  : 03-26-2024
 * @last modified by  : Cristian Vizzarri
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   03-25-2024   Cristian Vizzarri   Initial Version
**/
public with sharing class QuoteController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getQuotes() {
        List<SBQQ__Quote__c> quotes = [
            SELECT Id, Name,  SBQQ__Opportunity2__r.Name, SBQQ__Status__c, SBQQ__EndDate__c, SBQQ__TotalCustomerDiscountAmount__c
            FROM SBQQ__Quote__c
            WHERE IsDeleted = false AND Id = 'a0qHo00000FutPhIAJ'
        ];

        List<SBQQ__QuoteLine__c> qlList = [
            SELECT Id, Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__NetTotal__c, SBQQ__EffectiveStartDate__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotes[0].Id
        ];



        List<Map<String, Object>> response = new List<Map<String, Object>>(); 

        

        for (SBQQ__Quote__c quote : quotes) {
            Map<String, Object> quoteData = new Map<String, Object>();
            quoteData.put('Id', quote.Id);
            quoteData.put('Name', quote.Name);
            quoteData.put('OpportunityName', quote.SBQQ__Opportunity2__r.Name);
            quoteData.put('Total', quote.SBQQ__TotalCustomerDiscountAmount__c);
            quoteData.put('Status', quote.SBQQ__Status__c);
            quoteData.put('EffectiveDate', quote.SBQQ__EndDate__c);
            quoteData.put('QuoteLines', new List<Map<String, Object>>());

            for (SBQQ__QuoteLine__c quoteLine : qlList) {
                Map<String, Object> quoteLineData = new Map<String, Object>();
                quoteLineData.put('Id', quoteLine.Id);
                quoteLineData.put('Name', quoteLine.Name);
                quoteLineData.put('OpportunityName', quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name);
                quoteLineData.put('Total', quoteLine.SBQQ__NetTotal__c);
                //quoteLineData.put('Status', quoteLine.Status__c);
                quoteLineData.put('EffectiveDate', quoteLine.SBQQ__EffectiveStartDate__c);
                quoteLineData.put('fieldName', 'Name');
                quoteLineData.put('fieldType', 'text');
                quoteLineData.put('fieldLabel', 'Name');
                quoteLineData.put('fieldValue', quoteLine.Name);

                quoteData.put('QuoteLines', quoteLineData);
            }

            response.add(quoteData);
        }

        return response;
    }

    @AuraEnabled
    public static void updateQuoteLine(Id recordId, String fieldName, String fieldValue) {
        SBQQ__QuoteLine__c quoteLine = [
            SELECT Id, Name, SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__NetTotal__c
            FROM SBQQ__QuoteLine__c
            WHERE Id = :recordId
        ];

        if (fieldName == 'Name') {
            quoteLine.SBQQ__Description__c = fieldValue;
        } else if (fieldName == 'TotalPrice__c') {
            quoteLine.SBQQ__Description__c = fieldValue;
        }

        update quoteLine;
    }
}