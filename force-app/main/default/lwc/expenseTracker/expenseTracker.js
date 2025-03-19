import { LightningElement, track, wire } from 'lwc';
import saveExpense from '@salesforce/apex/ExpenseController.saveExpense';
import getConversionRate from '@salesforce/apex/ExpenseController.getConversionRate';

export default class ExpenseTracker extends LightningElement {
    @track amount = 0;
    @track category = '';
    @track expenseDate = '';
    @track currency = 'USD';
    @track convertedAmount = 0;
    
    handleInput(event) {
        this[event.target.name] = event.target.value;
    }

    async handleSave() {
        const conversionRate = await getConversionRate({ currency: this.currency });
        this.convertedAmount = this.amount * conversionRate;
        
        saveExpense({
            amount: this.convertedAmount,
            category: this.category,
            expenseDate: this.expenseDate,
            currency: this.currency
        })
        .then(() => {
            alert('Expense saved successfully!');
        })
        .catch(error => {
            console.error(error);
        });
    }
}
