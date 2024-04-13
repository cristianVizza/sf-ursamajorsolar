import { LightningElement, wire, api, track } from "lwc";
import getQuotes from "@salesforce/apex/QuoteController.getQuotes";
import updateQuoteLine from "@salesforce/apex/QuoteController.updateQuoteLine";

class TreeGridItem {
    constructor(id, name, children) {
        this.id = id;
        this.name = name;
        this.children = children;
    }
}


export default class EditNestedLines extends LightningElement {
    @track data = [
        new TreeGridItem('1', 'Parent 1', [
            new TreeGridItem('1.1', 'Child 1'),
            new TreeGridItem('1.2', 'Child 2'),
            new TreeGridItem('1.3', 'Child 3')
        ]),
        new TreeGridItem('2', 'Parent 2', [
            new TreeGridItem('2.1', 'Child 1'),
            new TreeGridItem('2.2', 'Child 2'),
            new TreeGridItem('2.3', 'Child 3')
        ]),
        new TreeGridItem('3', 'Parent 3', [
            new TreeGridItem('3.1', 'Child 1'),
            new TreeGridItem('3.2', 'Child 2'),
            new TreeGridItem('3.3', 'Child 3')
        ])
    ];

    @track columns = [
        {
            label: 'Name',
            fieldName: 'name',
            type: 'text',
            editable: true
        }
    ];

    // ...

    editingRow = null;

    handleRowAction(event) {
        console.log('handleRowAction');
        //if (event.detail.action.name === 'edit') {
            this.editingRow = event.detail.row;
        //}
    }

    handleSubmit(event) {
        event.preventDefault();
        this.editingRow.name = event.target.name.value;
        this.editingRow = null;
    }

}