public with sharing class ExpenseController {
    
    @AuraEnabled
    public static void saveExpense(Decimal amount, String category, Date expenseDate, String currencyCode) {
        Expense__c expense = new Expense__c(
            Amount__c = amount,
            Category__c = category,
            Expense_Date__c = expenseDate,
            Currency__c = currencyCode
        );
        insert expense;
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getConversionRate(String currencyCode) {
        String apiUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Decimal> rates = (Map<String, Decimal>) responseMap.get('rates');
            return rates.containsKey(currencyCode) ? rates.get(currencyCode) : 1;
        }
        return 1;
    }
    @AuraEnabled(cacheable=true)
public static List<Expense__c> getExpenses() {
    return [SELECT Name, Amount__c, Category__c, Expense_Date__c, Currency__c FROM Expense__c ORDER BY Expense_Date__c DESC];
}
}