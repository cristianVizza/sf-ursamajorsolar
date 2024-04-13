import { LightningElement, api } from 'lwc';

export default class ExampleLWC extends LightningElement {

    @api recordId;
    @api firedFrom;
    isOrder = false;
    isQuote = false;

    connectedCallback() {
        console.log('recordId: ' + this.recordId);
        console.log('firedFrom: ' + this.firedFrom);

        switch(this.firedFrom) {
            case 'Order':
                this.isOrder = true;
                break;
            case 'Quote':
                this.isQuote = true;
                break;
            default:
                break;
        }
    }
}