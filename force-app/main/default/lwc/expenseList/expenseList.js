import { LightningElement, track, wire } from 'lwc';
import getExpenses from '@salesforce/apex/ExpenseController.getExpenses';

export default class ExpenseList extends LightningElement {
    @track expenses = [];

    @wire(getExpenses)
    wiredExpenses({ data, error }) {
        if (data) {
            this.expenses = data;
        } else if (error) {
            console.error(error);
        }
    }
}
