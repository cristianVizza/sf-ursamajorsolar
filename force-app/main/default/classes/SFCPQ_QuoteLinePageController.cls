/**
 * @description       : 
 * @author            : Cristian Vizzarri
 * @group             : 
 * @last modified on  : 12-13-2023
 * @last modified by  : Cristian Vizzarri
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   12-13-2023   Cristian Vizzarri   Initial Version
**/
public with sharing class SFCPQ_QuoteLinePageController {

    @AuraEnabled(cacheable=true)
    public static List<quoteLineWrapper> getQuoteLines(Id quoteId) {

        List<quoteLineWrapper> qlWrapperList = new List<quoteLineWrapper>();
        Id qId = quoteId;
        for (SBQQ__QuoteLine__c ql : [SELECT Id, Name, SBQQ__EndDate__c, SBQQ__Quantity__c,
        SBQQ__StartDate__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__Account__r.Name,
        SBQQ__Quote__r.SBQQ__Opportunity2__r.Name 
        FROM SBQQ__QuoteLine__c WHERE Id = :qId ORDER BY Name ASC]) {
            quoteLineWrapper qlWrapper = new quoteLineWrapper();
            qlWrapper.wAccountName = ql.SBQQ__Quote__r.SBQQ__Account__r.Name;
            qlWrapper.wEndDate = ql.SBQQ__EndDate__c;
            qlWrapper.wStartDate = ql.SBQQ__StartDate__c;
            qlWrapper.wId = ql.Id;
            qlWrapper.wOpportunityName = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name;
            qlWrapper.wQuantity = Integer.valueOf(ql.SBQQ__Quantity__c);
            qlWrapper.wQuoteName = ql.SBQQ__Quote__r.Name;
            
            qlWrapperList.add(qlWrapper);
        }

        return qlWrapperList;
    }

    public class quoteLineWrapper{

        @AuraEnabled
        public Id wId {get;set;}
        @AuraEnabled 
        public String wQuoteName {get;set;}
        @AuraEnabled 
        public Date wStartDate {get;set;}
        @AuraEnabled 
        public Date wEndDate {get;set;}
        @AuraEnabled 
        public String wAccountName {get;set;}
        @AuraEnabled 
        public String wOpportunityName {get;set;}
        @AuraEnabled 
        public Integer wQuantity {get;set;}


    }
}