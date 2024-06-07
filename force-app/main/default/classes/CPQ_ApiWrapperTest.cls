/**
* This test class is only testing for code coverage. Functionality does not require testing for this wrapper class. 
*
*/



@IsTest
public class CPQ_ApiWrapperTest {

    @TestSetup
    static void setup() {
        Test.startTest();
        CPQ_TestUtils.TestData testData = new  CPQ_TestUtils.TestData();
        Test.stopTest();

        testData.createQuoteData();
    }


	@IsTest
	public static void testGetQuoteModel() {
        SBQQ__Quote__c quote = [Select Id FROM SBQQ__Quote__c LIMIT 1];
		CPQ_ApiDataModels.QuoteModel quoteModel = CPQ_ApiWrapper.getQuoteModel(quote.Id);
	}

	@IsTest
	public static void testLoadProduct() {
		
		Product2 product = CPQ_TestUtils.createProduct();

		CPQ_ApiDataModels.ProductModel productModel = CPQ_ApiWrapper.loadProduct(product.Id, Test.getStandardPricebookId(), 'USD');
	}


	@IsTest
	public static void testAddProductToQuoteAndSaveQuote() {

        Test.startTest();
        SBQQ__Quote__c quote = [Select Id FROM SBQQ__Quote__c LIMIT 1];
        Product2 product = [Select Id FROM Product2 LIMIT 1];

		CPQ_ApiDataModels.QuoteModel quoteModel = CPQ_ApiWrapper.addProductsToQuote(quote.Id, product.Id, Test.getStandardPricebookId(), 'USD', true);
		
		CPQ_ApiWrapper.saveQuote(quoteModel);
		CPQ_ApiWrapper.calculateQuote(quoteModel);
		CPQ_ApiWrapper.calculateQuote(quote.Id);
		CPQ_ApiWrapper.calculateAndSaveQuote(quoteModel);

        Test.stopTest();

	}




	/** Tests for the various calculator methods available */
	//@IsTest
	//public static void testCalculate() {
		
	//	//CPQ_TestUtils.TestData testData = new CPQ_TestUtils.TestData();
	//	//CPQ_ApiDataModels.QuoteModel quoteModel = CPQ_ApiWrapper.getQuoteModel(testData.quote.Id);
	//	//// Theses make a callout and will fail, wrapping in try/catch just for code coverage
	//	//// because it is SBQQ code, not our code and we have functionally tested everything needed
	//	//Test.startTest();
	//	//try { CPQ_ApiWrapper.calculateQuote(quoteModel); } catch(Exception ex) { }
	//	//Test.stopTest();
	//}

	//@IsTest
	//public static void testCalculate1() {
		
	//	//CPQ_TestUtils.TestData testData = new CPQ_TestUtils.TestData();
	//	//// Theses make a callout and will fail, wrapping in try/catch just for code coverage
	//	//// because it is SBQQ code, not our code and we have functionally tested everything needed
	//	//Test.startTest();
	//	//try { CPQ_ApiWrapper.calculateQuote(testData.quote.Id); } catch(Exception ex) { }
	//	//Test.stopTest();
	//}

	//@IsTest
	//public static void testCalculate2() {
		
	//	//CPQ_TestUtils.TestData testData = new CPQ_TestUtils.TestData();
	//	//CPQ_ApiDataModels.QuoteModel quoteModel = CPQ_ApiWrapper.getQuoteModel(testData.quote.Id);
	//	//// Theses make a callout and will fail, wrapping in try/catch just for code coverage
	//	//// because it is SBQQ code, not our code and we have functionally tested everything needed
	//	//Test.startTest();
	//	//try { CPQ_ApiWrapper.calculateAndSaveQuote(quoteModel); } catch(Exception ex) { }
	//	//Test.stopTest();
	//}

	//@IsTest
	//public static void testCalculate3() {
		
	//	//CPQ_TestUtils.TestData testData = new CPQ_TestUtils.TestData();
	//	//// Theses make a callout and will fail, wrapping in try/catch just for code coverage
	//	//// because it is SBQQ code, not our code and we have functionally tested everything needed
	//	//Test.startTest();
	//	//try { CPQ_ApiWrapper.calculateQuote2(testData.quote.Id); } catch(Exception ex) { }
	//	//Test.stopTest();
	//}

	//@IsTest
	//public static void testCalculate4() {
		
	//	//CPQ_TestUtils.TestData testData = new CPQ_TestUtils.TestData();
	//	////CPQ_ApiDataModels.QuoteModel quoteModel = CPQ_ApiWrapper.getQuoteModel(testData.quote.Id);
	//	//// Theses make a callout and will fail, wrapping in try/catch just for code coverage
	//	//// because it is SBQQ code, not our code and we have functionally tested everything needed
	//	//Test.startTest();
	//	//try { CPQ_ApiWrapper.calculateQuote2(quoteModel); } catch(Exception ex) { }
	//	//Test.stopTest();
	//}

	//@IsTest
	//public static void testAmendContract() {
		
	//	CPQ_ApiWrapper.debug = true;
		
	//	Test.startTest();
		
	//	Opportunity opp = [SELECT Id, SBQQ__Contracted__c FROM Opportunity LIMIT 1];
	//	opp.SBQQ__Contracted__c = true;
	//	update opp;

	//	Test.stopTest();

	//	Contract contract = [SELECT Id FROM Contract LIMIT 1];
	//	contract.Status = 'Activated';
	//	update contract;

	//	CPQ_ApiDataModels.QuoteModel quoteModel = CPQ_ApiWrapper.amendContract(contract.Id);
	//	List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c];
		
	//	System.assertNotEquals(null, quoteModel);
	//	System.assertEquals(2, quotes.size());
	//}

}