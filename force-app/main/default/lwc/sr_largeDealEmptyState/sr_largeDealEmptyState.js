import { LightningElement, api } from 'lwc';

export default class Sr_largeDealEmptyState extends LightningElement {
    @api heading = 'Nothing to Show';// Default value
    @api subHeading;

    get hasSubheading(){
        return !!this.subHeading;
    }
}