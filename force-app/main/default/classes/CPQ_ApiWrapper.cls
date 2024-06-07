/**
 *
 *
 * @description This class wraps the Salesforce CPQ API to allow
 * easier interaction and to demonstrate how to call various methods
 * EXAMPLE INVOKING:
 * Contract contract = [SELECT Id FROM Contract WHERE Id = '800f4000000DL11' LIMIT 1];
 * CPQ_ApiWrapper.renewContract(contract);
 * To Manually call the CPQ API via REST, the convention is as follows:
 * GET /services/apexrest/SBQQ/ServiceRouter/read?reader=SBQQ.QuoteAPI.QuoteReader&uid=a0nf4000000W4vs
 *
 */
public without sharing class CPQ_ApiWrapper {

    public static Boolean debug = true;

    /** CPQ API METHODS */
    public static final String CONTRACT_RENEWER = 'SBQQ.ContractManipulationAPI.ContractRenewer';
    public static final String CONTRACT_AMENDER = 'SBQQ.ContractManipulationAPI.ContractAmender';

    public static final String CONFIG_LOADER = 'SBQQ.ConfigAPI.ConfigLoader';
    public static final String LOAD_RULE_EXECUTOR = 'SBQQ.ConfigAPI.LoadRuleExecutor';
    public static final String CONFIGURATION_VALIDATOR = 'SBQQ.ConfigAPI.ConfigurationValidator';

    public static final String PRODUCT_LOADER = 'SBQQ.ProductAPI.ProductLoader';
    public static final String PRODUCT_SUGGESTER = 'SBQQ.ProductAPI.ProductSuggester';
    public static final String PRODUCT_SEARCHER = 'SBQQ.ProductAPI.ProductSearcher';

    public static final String QUOTE_READER = 'SBQQ.QuoteAPI.QuoteReader';
    public static final String QUOTE_PRODUCT_ADDER = 'SBQQ.QuoteAPI.QuoteProductAdder';
    public static final String QUOTE_CALCULATOR = 'SBQQ.QuoteAPI.QuoteCalculator';
    public static final String QUOTE_SAVER = 'SBQQ.QuoteAPI.QuoteSaver';


    /** Mini Wrapper around SBQQ API METHODS */
    private static String read(String name, String uid) {
        return SBQQ.ServiceRouter.read(name, uid);
    }
    private static String load(String name, String uid, Object payload) {
        return loadStr(name, uid, JSON.serialize(payload));
    }
    private static String loadStr(String name, String uid, String payloadJson) {
        return SBQQ.ServiceRouter.load(name, uid, payloadJson);
    }
    private static String save(String name, Object model) {
        return saveStr(name, JSON.serialize(model));
    }
    private static String saveStr(String name, String modelJson) {
        return SBQQ.ServiceRouter.save(name, modelJson);
    }

    // Will need to add unit tests for these if uncommented
    //public static List<CPQ_ApiDataModels.QuoteModel> renewContract(Contract contract) {
    //  return renewContract(contract.Id, new List<Contract>{contract});
    //}
    //public static List<CPQ_ApiDataModels.QuoteModel> renewContract(Id contractId, List<Contract> contracts) {
    //  CPQ_ApiDataModels.RenewalContext payload = new CPQ_ApiDataModels.RenewalContext();
    //  payload.renewedContracts = contracts;
    //  String jsonResult = load(CONTRACT_RENEWER, (String) contractId, payload);
    //  if(debug) {
    //      System.debug(LoggingLevel.WARN, 'jsonResult: ' + jsonResult);
    //  }

    //  List<CPQ_ApiDataModels.QuoteModel> quoteModel = (List<CPQ_ApiDataModels.QuoteModel>) JSON.deserialize(jsonResult, LIST<CPQ_ApiDataModels.QuoteModel>.class);
    //  if(debug) {
    //      System.debug(LoggingLevel.WARN, 'jsonResult: ' + jsonResult);
    //      System.debug(LoggingLevel.WARN, 'quoteModel: ' + quoteModel);
    //  }
    //  return quoteModel;
    //}

    //public static CPQ_ApiDataModels.QuoteModel amendContract(Id contractId) {
    //    System.debug(LoggingLevel.WARN, 'amending');
    //    String jsonResult = load(CONTRACT_AMENDER, (String) contractId, null);
    //    System.debug(LoggingLevel.WARN, 'amended ' + jsonResult);
    //    CPQ_ApiDataModels.QuoteModel quoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(jsonResult, CPQ_ApiDataModels.QuoteModel.class);
    //    System.debug(LoggingLevel.WARN, 'quoteModel >>> ' + quoteModel);
        //if(debug) {
        //    System.debug(LoggingLevel.WARN, 'jsonResult: ' + jsonResult);
        //    System.debug(LoggingLevel.WARN, 'quoteModel: ' + quoteModel);
        //}
        //return quoteModel;
    //}


    /**
     * ******* QUOTE API EXAMPLES ********
     */
    public static CPQ_ApiDataModels.QuoteModel getQuoteModel(Id quoteId) {
        String jsonResult = read(QUOTE_READER, (String) quoteId);
        CPQ_ApiDataModels.QuoteModel quoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(jsonResult, CPQ_ApiDataModels.QuoteModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'jsonResult: ' + jsonResult);
            System.debug(LoggingLevel.WARN, 'quoteModel: ' + quoteModel);
        }
        return quoteModel;
    }

    public static CPQ_ApiDataModels.ProductModel loadProduct(Id productId, Id pricebookId, String currencyCode) {
        CPQ_ApiDataModels.ProductLoadContext productLoadPayload = new CPQ_ApiDataModels.ProductLoadContext(pricebookId, currencyCode);
        String jsonResultProduct = load(PRODUCT_LOADER, (String) productId, productLoadPayload);
        CPQ_ApiDataModels.ProductModel productModel = (CPQ_ApiDataModels.ProductModel) JSON.deserialize(jsonResultProduct, CPQ_ApiDataModels.ProductModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'jsonResultProduct: ' + jsonResultProduct);
            System.debug(LoggingLevel.WARN, 'productModel: ' + productModel);
        }
        return productModel;
    }

    public static CPQ_ApiDataModels.ProductModel setOptionsConfigured(CPQ_ApiDataModels.ProductModel productModel) {
        if(productModel.configuration != null){
            productModel.configuration.configured = true;
            productModel.configuration.configurationEntered = true;
            for(CPQ_ApiDataModels.ConfigurationModel configModel : productModel.configuration.optionConfigurations) {
                configModel.configured = true;
                configModel.configurationEntered = true;
            }
            return productModel;
        }else{return productModel;}
        
    }

    public static CPQ_ApiDataModels.QuoteModel addProductsToQuote(Id quoteId, Id productId, Id pricebookId, String currencyCode) {
        return addProductsToQuote(quoteId, pricebookId, productId, currencyCode, false);
    }
    public static CPQ_ApiDataModels.QuoteModel addProductsToQuote(Id quoteId, Id productId, Id pricebookId, String currencyCode, Boolean skipCalculate) {
        CPQ_ApiDataModels.ProductModel productModel = loadProduct(productId, pricebookId, currencyCode);

        // Set product model as configured and configurationEntered
        productModel = setOptionsConfigured(productModel);

        String jsonResultQuote = read(QUOTE_READER, (String) quoteId);
        CPQ_ApiDataModels.QuoteModel initialQuoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(jsonResultQuote, CPQ_ApiDataModels.QuoteModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'jsonResultQuote: ' + jsonResultQuote);
            System.debug(LoggingLevel.WARN, 'initialQuoteModel: ' + initialQuoteModel);
        }

        CPQ_ApiDataModels.ProductAddContext productAddPayload = new CPQ_ApiDataModels.ProductAddContext(skipCalculate, initialQuoteModel, new List<CPQ_ApiDataModels.ProductModel>{productModel});

        return addProductsToQuote(productAddPayload);

    }



    public static CPQ_ApiDataModels.QuoteModel addProductsToQuote(CPQ_ApiDataModels.ProductAddContext productAddPayload) {
        if(debug) {
            System.debug(LoggingLevel.WARN, 'productAddPayloadJSON: ' + JSON.serialize(productAddPayload));
        }
        String updatedQuoteJSON = load(QUOTE_PRODUCT_ADDER, null, productAddPayload);
        CPQ_ApiDataModels.QuoteModel updatedQuoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(updatedQuoteJSON, CPQ_ApiDataModels.QuoteModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'updatedQuoteJSON: ' + updatedQuoteJSON);
            System.debug(LoggingLevel.WARN, 'updatedQuoteModel: ' + updatedQuoteModel);
        }

        return updatedQuoteModel;
    }

    public static CPQ_ApiDataModels.QuoteModel calculateQuote(CPQ_ApiDataModels.QuoteModel quoteModel) {
        CPQ_ApiDataModels.CalculatorContext calculatorPayload = new CPQ_ApiDataModels.CalculatorContext(quoteModel);

        String updatedQuoteJSON = load(QUOTE_CALCULATOR, null, calculatorPayload);
        CPQ_ApiDataModels.QuoteModel updatedQuoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(updatedQuoteJSON, CPQ_ApiDataModels.QuoteModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'updatedQuoteJSON: ' + updatedQuoteJSON);
            System.debug(LoggingLevel.WARN, 'updatedQuoteModel: ' + updatedQuoteModel);
        }

        return updatedQuoteModel;
    }


    public static CPQ_ApiDataModels.QuoteModel saveQuote(CPQ_ApiDataModels.QuoteModel quoteModel) {
        String savedQuoteJSON = save(QUOTE_SAVER, quoteModel);

        CPQ_ApiDataModels.QuoteModel updatedQuoteModel = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(savedQuoteJSON, CPQ_ApiDataModels.QuoteModel.class);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'updatedQuoteModel: ' + updatedQuoteModel);
        }

        return updatedQuoteModel;
    }

    public static CPQ_ApiDataModels.QuoteModel calculateAndSaveQuote(CPQ_ApiDataModels.QuoteModel quoteModel) {
        //String calculatedQuoteJSON = SBQQ.QuoteLineEditorController.calculateQuote2(quoteModel.record.Id, JSON.serialize(quoteModel));
        // Attempt to get around uncomitted changes by saving first
        String savedQuoteJSON = saveStr(QUOTE_SAVER, JSON.serialize(quoteModel));
        //String calculatedQuoteJSON = SBQQ.QuoteLineEditorController.calculateQuote2(quoteModel.record.Id, JSON.serialize(savedQuoteJSON));
        //savedQuoteJSON = saveStr(QUOTE_SAVER, calculatedQuoteJSON);
        CPQ_ApiDataModels.QuoteModel savedQuote = (CPQ_ApiDataModels.QuoteModel) JSON.deserialize(savedQuoteJSON, CPQ_ApiDataModels.QuoteModel.class);
        //String calculatedQuoteJSON = SBQQ.QuoteLineEditorController.calculateQuote2(quoteModel.record.Id, JSON.serialize(savedQuoteJSON));
        if(debug) {
            //System.debug(LoggingLevel.WARN, 'calculatedQuoteJSON: ' + calculatedQuoteJSON);
            System.debug(LoggingLevel.WARN, 'savedQuoteJSON: ' + savedQuoteJSON);
            //System.debug(LoggingLevel.WARN, 'savedQuote: ' + savedQuote);
        }
        return savedQuote;
    }

    //public static void configureBundle(CPQ_ApiDataModels.QuoteModel quoteModel, Id productId) {
    //    //CPQ_ApiDataModels.ConfigLoadContext context = new CPQ_ApiDataModels.ConfigLoadContext();
    //    // Using alt payload to avoid requiring tiny quoteModel since it is basically the same - could modify contrstructor to convert
    //    CPQ_ApiDataModels.TinyQuoteModel tinyQuoteModel = new CPQ_ApiDataModels.TinyQuoteModel();
    //    tinyQuoteModel.record = quoteModel.record;

    //    CPQ_ApiDataModels.ConfigLoadContext context = new CPQ_ApiDataModels.ConfigLoadContext();
    //    context.quote = tinyQuoteModel;

    //    System.debug(LoggingLevel.WARN, JSON.serialize(context));
    //    String configLoaderJSON = load(CONFIG_LOADER, (String) productId, JSON.serialize(context));
    //    if(debug) {
    //        System.debug(LoggingLevel.WARN, 'configLoaderJSON: ' + configLoaderJSON);
    //    }
    //}

    /**
     * Force a re-calculation of provided quote
     * @param  quoteId [description]
     * @return         [description]
     */
    public static CPQ_ApiDataModels.QuoteModel calculateQuote(String quoteId) {
        CPQ_ApiDataModels.QuoteModel initialQuoteModel = getQuoteModel(quoteId);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'initialQuoteModel: ' + initialQuoteModel);
        }

        CPQ_ApiDataModels.QuoteModel calculatedQuoteModel = calculateQuote(initialQuoteModel);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'calculatedQuoteModel: ' + calculatedQuoteModel);
        }

        CPQ_ApiDataModels.QuoteModel savedQuoteModel = saveQuote(calculatedQuoteModel);
        if(debug) {
            System.debug(LoggingLevel.WARN, 'savedQuoteModel: ' + savedQuoteModel);
        }

        return savedQuoteModel;
    }

}