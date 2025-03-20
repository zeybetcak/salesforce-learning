public with sharing class ExpenseController {
    
    @AuraEnabled
    public static void saveExpense(Decimal amount, String category, Date expenseDate, String currencyCode) {
        try {
            // ✅ Debugging: Log input values
            System.debug('🚀 Attempting to insert Expense: Amount=' + amount + ', Category=' + category + ', Expense Date=' + expenseDate + ', Currency=' + currencyCode);
    
            // ✅ Ensure required fields are provided
            if (amount == null || category == null || expenseDate == null) {
                throw new AuraHandledException('❌ Missing required fields. Please enter all values.');
            }
    
            // ✅ Set a default currency if it's null or blank
            if (String.isBlank(currencyCode)) {
                System.debug('⚠️ Currency Code is blank. Defaulting to USD.');
                currencyCode = 'USD';
            }
    
            // ✅ Create new Expense record
            Expense__c expense = new Expense__c(
                Amount__c = amount,
                Category__c = category,
                Expense_Date__c = expenseDate,
                Currency__c = currencyCode
            );
    
            insert expense;
    
            System.debug('✅ Expense inserted successfully: ' + expense.Id);
    
        } catch (DmlException e) {
            System.debug('❌ DML Exception: ' + e.getDmlMessage(0));
            throw new AuraHandledException('❌ Error saving expense: ' + e.getDmlMessage(0));
        } catch (Exception ex) {
            System.debug('❌ Unexpected Exception: ' + ex.getMessage());
            throw new AuraHandledException('❌ Unexpected error: ' + ex.getMessage());
        }
    }
        
    @AuraEnabled(cacheable=true)
public static Decimal getConversionRate(String currencyCode) {
    System.debug('🚀 getConversionRate called with currencyCode: ' + currencyCode);

    // ✅ Ensure currencyCode is not null
    if (String.isBlank(currencyCode)) {
        System.debug('⚠️ currencyCode is null or blank. Defaulting to USD.');
        currencyCode = 'USD';
    }

    String apiUrl = 'https://api.exchangerate-api.com/v4/latest/USD';

    HttpRequest req = new HttpRequest();
    req.setEndpoint(apiUrl);
    req.setMethod('GET');

    Http http = new Http();
    HttpResponse res = http.send(req);

    if (res.getStatusCode() == 200) {
        System.debug('🌍 API Response: ' + res.getBody());

        // ✅ Deserialize API Response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        if (responseMap != null && responseMap.containsKey('rates')) {
            Map<String, Object> ratesMap = (Map<String, Object>) responseMap.get('rates');

            if (ratesMap != null && ratesMap.containsKey(currencyCode)) {
                Object rateValue = ratesMap.get(currencyCode);

                // ✅ Convert to Decimal
                Decimal exchangeRate;
                if (rateValue instanceof Double) {
                    exchangeRate = Decimal.valueOf((Double) rateValue);
                } else if (rateValue instanceof Integer) {
                    exchangeRate = Decimal.valueOf((Integer) rateValue);
                } else if (rateValue instanceof String) {
                    exchangeRate = Decimal.valueOf(Double.valueOf((String) rateValue));
                } else {
                    throw new System.TypeException('Unexpected type returned from API: ' + rateValue);
                }

                // ✅ Convert USD → TRY to TRY → USD
                Decimal correctRate = 1 / exchangeRate;
                System.debug('🌍 Corrected Rate (TRY to USD): ' + correctRate);
                return correctRate;
            } else {
                System.debug('❌ Currency Code not found in API response: ' + currencyCode);
            }
        } else {
            System.debug('❌ API response does not contain "rates" field.');
        }
    } else {
        System.debug('❌ API Request Failed. Status Code: ' + res.getStatusCode());
    }
    return 1; // Default to 1 if API call fails
}

    @AuraEnabled(cacheable=true)
    public static List<Expense__c> getExpenses() {
        return [SELECT Name, Amount__c, Category__c, Expense_Date__c, Currency__c FROM Expense__c ORDER BY Expense_Date__c DESC];
    }
}