import { LightningElement, track } from 'lwc';
import saveExpense from '@salesforce/apex/ExpenseController.saveExpense';
import getConversionRate from '@salesforce/apex/ExpenseController.getConversionRate';

export default class ExpenseTracker extends LightningElement {
    @track amount = 0;
    @track category = '';
    @track expenseDate = '';
    @track currencyCode = ''; // ✅ No default value
    @track convertedAmount = 0;

    categoryOptions = [
        { label: 'Food', value: 'Food' },
        { label: 'Travel', value: 'Travel' },
        { label: 'Shopping', value: 'Shopping' },
        { label: 'Bills', value: 'Bills' }
    ];

    // ✅ Currency selection options
    currencyOptions = [
        { label: 'Select a currency', value: '' },
        { label: 'US Dollar (USD)', value: 'USD' },
        { label: 'Euro (EUR)', value: 'EUR' },
        { label: 'British Pound (GBP)', value: 'GBP' },
        { label: 'Turkish Lira (TRY)', value: 'TRY' },
        { label: 'Canadian Dollar (CAD)', value: 'CAD' },
        { label: 'Japanese Yen (JPY)', value: 'JPY' }
    ];

    handleInput(event) {
        this[event.target.name] = event.target.value;
    }

    async handleSave() {
        console.log('🚀 Save button clicked');
        console.log('Amount Entered:', this.amount);
        console.log('Selected Currency (Before Fix):', this.currencyCode);

        // ✅ Check if currency is selected
        if (!this.currencyCode || this.currencyCode.trim() === '') {
            alert('⚠️ Please select a currency before saving.');
            return;
        }

        console.log('Selected Currency (After Fix):', this.currencyCode);

        try {
            console.log('📤 Calling Apex with:', { currencyCode: this.currencyCode });

            const conversionRate = await getConversionRate({ currencyCode: this.currencyCode });
            console.log('🌍 API Conversion Rate:', conversionRate);

            if (conversionRate !== null && conversionRate !== undefined) {
                this.convertedAmount = this.amount * conversionRate;
                console.log('💰 Converted Amount in USD:', this.convertedAmount);
            } else {
                console.error('❌ Conversion Rate is NULL');
                this.convertedAmount = this.amount; // Fallback to same amount
            }

            await saveExpense({
                amount: this.convertedAmount,
                category: this.category,
                expenseDate: this.expenseDate,
                currencyCode: this.currencyCode
            });

            alert(`✅ Expense saved! Converted Amount: ${this.convertedAmount} USD`);
        } catch (error) {
            console.error('❌ Error saving expense:', error);
        }
    }
}