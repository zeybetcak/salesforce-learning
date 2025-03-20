import { LightningElement, wire, track } from 'lwc';
import getExpenses from '@salesforce/apex/ExpenseController.getExpenses';
import { refreshApex } from '@salesforce/apex';

export default class ExpenseList extends LightningElement {
    @track expenses = [];
    wiredExpensesResult;

    @wire(getExpenses)
    wiredExpenses(result) {
        this.wiredExpensesResult = result; // ✅ Store for refresh
        if (result.data) {
            console.log('🚀 Retrieved Expenses:', result.data);

            this.expenses = result.data.map(expense => {
                let displayAmount = expense.Amount__c; // ✅ Always use stored amount
                let displayCurrency = expense.Currency__c; // ✅ Default to original currency

                // ✅ If conversion happened (i.e., stored as USD but labeled as another currency)
                if (expense.Currency__c !== 'USD' && expense.Conversion_Rate__c && expense.Conversion_Rate__c !== 1) {
                    displayCurrency = 'USD'; // ✅ Ensure converted values are always labeled as USD
                }

                console.log(`🔹 Processed Expense: ${expense.Category__c} - ${displayAmount} ${displayCurrency}`);

                return {
                    ...expense,
                    formattedAmount: `${displayAmount} ${displayCurrency}`, // ✅ Correctly labeled converted amount
                    category: expense.Category__c,
                    date: expense.Expense_Date__c
                };
            });

            console.log('🔄 Final Processed Expenses:', JSON.stringify(this.expenses));
        } else if (result.error) {
            console.error('❌ Error retrieving expenses:', result.error);
        }
    }

    connectedCallback() {
        window.addEventListener('refreshlist', () => {
            console.log('🔄 Refreshing Expense List after new expense.');
            refreshApex(this.wiredExpensesResult);
        });
    }
}










