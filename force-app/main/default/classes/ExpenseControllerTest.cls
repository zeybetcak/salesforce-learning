@isTest
public class ExpenseControllerTest {

    @testSetup
    static void setupTestData() {
        // ✅ Insert test expenses
        List<Expense__c> testExpenses = new List<Expense__c>();

        for (Integer i = 1; i <= 3; i++) {
            testExpenses.add(new Expense__c(
                Amount__c = 100 * i,
                Category__c = 'Test Category ' + i,
                Expense_Date__c = Date.today().addDays(-i),
                Currency__c = 'USD'
            ));
        }
        insert testExpenses;
        System.debug('✅ Inserted ' + testExpenses.size() + ' test records.');
    }

    @isTest
    static void testSaveExpense() {
        Test.startTest();
        // ✅ Call the method with test data
        ExpenseController.saveExpense(150, 'Food', Date.today(), 'EUR');

        // ✅ Verify the record was created
        Expense__c savedExpense = [SELECT Id, Amount__c, Category__c, Currency__c FROM Expense__c WHERE Currency__c = 'EUR' LIMIT 1];

        System.assertNotEquals(null, savedExpense.Id, '❌ Expense was not saved!');
        System.assertEquals(150, savedExpense.Amount__c, '❌ Amount mismatch!');
        System.assertEquals('Food', savedExpense.Category__c, '❌ Category mismatch!');
        System.assertEquals('EUR', savedExpense.Currency__c, '❌ Currency mismatch!');
        Test.stopTest();
    }

    @isTest
    static void testSaveExpenseWithMissingFields() {
        Test.startTest();
        try {
            // ✅ Missing category should throw an error
            ExpenseController.saveExpense(150, null, Date.today(), 'USD');
            System.assert(false, '❌ Expected an AuraHandledException for missing fields.');
        } catch (AuraHandledException e) {
            System.debug('✅ Caught expected AuraHandledException: ' + e.getMessage());
            System.assert(e.getMessage().contains('❌ Missing required fields'), '❌ Incorrect error message.');
        }
        Test.stopTest();
    }

    @isTest
    static void testSaveExpenseDmlException() {
        Test.startTest();
        try {
            // ✅ Try inserting an invalid record
            ExpenseController.saveExpense(null, 'Bills', Date.today(), 'USD');
            System.assert(false, '❌ Expected an AuraHandledException for DML error.');
        } catch (AuraHandledException e) {
            System.debug('✅ Caught expected DML Exception: ' + e.getMessage());
            System.assert(e.getMessage().contains('❌ Error saving expense'), '❌ Incorrect DML error message.');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetConversionRate() {
        Test.startTest();
        // ✅ Mock API Response
        Test.setMock(HttpCalloutMock.class, new MockExchangeRateResponse());

        Decimal conversionRate = ExpenseController.getConversionRate('TRY');
        System.debug('🌍 Mocked Conversion Rate: ' + conversionRate);

        // ✅ Ensure the conversion rate is as expected
        System.assert(conversionRate > 0, '❌ Conversion rate should be greater than 0!');
        System.assert(conversionRate < 1, '❌ TRY to USD rate should be a fraction!');
        Test.stopTest();
    }

    @isTest
    static void testGetConversionRateWithNullCurrency() {
        Test.startTest();
        // ✅ Mock API Response
        Test.setMock(HttpCalloutMock.class, new MockExchangeRateResponse());

        Decimal conversionRate = ExpenseController.getConversionRate(null);
        System.debug('🌍 Mocked Conversion Rate (defaulted): ' + conversionRate);

        // ✅ Should default to USD
        System.assertEquals(1, conversionRate, '❌ Default conversion rate should be 1 for USD.');
        Test.stopTest();
    }

    @isTest
    static void testGetExpenses() {
        Test.startTest();
        // ✅ Call the method
        List<Expense__c> expenses = ExpenseController.getExpenses();

        // ✅ Ensure it returns at least the test records
        System.assert(expenses.size() > 0, '❌ No expenses returned!');
        System.assertEquals(3, expenses.size(), '❌ Unexpected number of expenses!');
        Test.stopTest();
    }
}