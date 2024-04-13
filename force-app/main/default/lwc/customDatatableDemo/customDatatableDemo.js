/* eslint-disable guard-for-in */
/* eslint-disable no-prototype-builtins */
import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedRecords from '@salesforce/apex/OpportunityRelatedListController.getRelatedRecords';
import saveDraftValues from '@salesforce/apex/OpportunityRelatedListController.saveDraftValues';

const COLUMNS = [
    //{ label: 'Select', type: 'boolean', fieldName: 'isSelected', editable: true },
    {
        label: 'Opportunity Name',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        }
    },
    {
        label: 'Account Name',
        fieldName: 'AccountId',
        type: 'lookup',
        typeAttributes: {
            placeholder: 'Choose Account',
            object: 'Opportunity',
            fieldName: 'AccountId',
            label: 'Account',
            value: { fieldName: 'AccountId' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Account',
            fields: ['Account.Name'],
            target: '_self'
        },
        //editable: true,
        cellAttributes: {
            class: { fieldName: 'accountNameClass' }
        }
    },
    {
        label: 'Pricebook Name',
        fieldName: 'Pricebook2Id',
        type: 'lookup',
        typeAttributes: {
            placeholder: 'Choose Pricebook',
            object: 'Opportunity',
            fieldName: 'Pricebook2Id',
            label: 'Pricebook',
            value: { fieldName: 'Pricebook2Id' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Pricebook2',
            fields: ['Pricebook2.Name'],
            target: '_self'
        },
        //editable: true,
        cellAttributes: {
            class: { fieldName: 'priceBookNameClass' }
        }
    },
    
    {
        label: 'Stage',
        fieldName: 'StageName',
        type: 'text',
        editable: true
    },
    {
        label: 'Description',
        fieldName: 'Description',
        type: 'text',
        editable: true
    },

    {
        label: 'Amount',
        fieldName: 'Amount',
        type: 'currency',
        editable: true
    },
    {
        label: 'Close Date',
        fieldName: 'CloseDate',
        type: 'date-local',
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric'
        },
        editable: true
    }
];

const PAGE_SIZE = 10;

export default class CustomDatatableDemo extends LightningElement {
    columns = COLUMNS;
    records = [];
    displayedRecords = [];
    lastSavedData;
    error;
    accountId;
    wiredRecords;
    showSpinner = false;
    draftValues = [];
    privateChildren = {}; //used to get the datatable lookup as private childern of customDatatable
    currentPage = 1;
    totalPages = 1;
    totalRecords = 0;
    //selection = [];
    @track selection = [];

    rowSelection(evt) {
        console.log('rowSelection');
        console.log(evt);
        console.log('-----');
        console.log(evt.detail);
        console.log('-----');
        console.log(JSON.stringify(evt.detail));
        console.log('-----');
        console.log(evt.detail.selectedRows);
        console.log('-----');
        console.log(JSON.stringify(evt.detail.selectedRows));

        //const selectedRowIds = evt.detail.selectedRows.map(row => row.id);
        //this.selectedRows = this.data.filter(row => selectedRowIds.includes(row.id));
        this.selection = evt.detail.selectedRows.map(row => row.Id);

    }
    renderedCallback() {
        //console.log('renderedCallback');
        if (!this.isComponentLoaded) {
            /* Add Click event listener to listen to window click to reset the lookup selection 
            to text view if context is out of sync*/
            window.addEventListener('click', (evt) => {
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
        }
    }

    disconnectedCallback() {
        window.removeEventListener('click', () => { });
    }

    handleWindowOnclick(context) {
        this.resetPopups('c-datatable-lookup', context);
    }

    //create object value of datatable lookup markup to allow to call callback function with window click event listener
    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    }

    //wire function to get the opportunity records on load
    @wire(getRelatedRecords)
    wiredRelatedRecords(result) {
        this.wiredRecords = result;
        const { data, error } = result;
        if (data) {
            this.records = data;
            this.totalRecords = data.length;
            this.totalPages = Math.ceil(data.length / PAGE_SIZE);
            this.updateRecords();
            this.error = undefined;
        } else if (error) {
            this.records = undefined;
            this.error = error;
        } else {
            this.error = undefined;
            this.records = undefined;
        }
        this.lastSavedData = this.records;
        this.showSpinner = false;
    }

    updateRecords() {
        const startIndex = (this.currentPage - 1) * PAGE_SIZE;
        const endIndex = startIndex + PAGE_SIZE;
        this.displayedRecords = JSON.parse(JSON.stringify(this.records.slice(startIndex, endIndex)));
        this.displayedRecords.forEach(record => {
            record.linkName = '/' + record.Id;
            record.accountNameClass = 'slds-cell-edit';
        });
    }

    updateSelection(){
        console.log('UpdateRecodsSelection');
        console.log('selection: ' + this.selection);
        console.log('selection typeof: ' + typeof this.selection);
        console.log('selection length: ' + this.selection.length);
        console.log('---------------------');
        let selectedItems = JSON.parse(window.localStorage.getItem('selection')); //string
        console.log('selectedItems: ' + selectedItems);
        console.log('selectedItems typeof: ' + typeof selectedItems);
        console.log('selectedItems length: ' + selectedItems.length);
        console.log(selectedItems);
        console.log('selectedItems stringify: ' + JSON.stringify(selectedItems));
        
        //Manually String
       /*  let string = "[";
        selectedItems.forEach((item) => {
            console.log('item: ' + item);
            string = string + "\"" + item + "\",";
        });
        string = string.substring(0, string.length - 1) + "]";
        console.log('string: ' + string); */

        //this.selection =  ["006Ho00000TTN5WIAX","006Ho00000TTN55IAH","006Ho00000TTN5DIAX"];
        this.selection = selectedItems;
        
        console.log('this.selection after: ' + this.selection);
    }


    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateRecords();
            this.updateSelection();
        }

    }
    
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateRecords();
            this.updateSelection()
        }
    }

    handleSelectAll(event) {
        //const selectedRows = event.detail.selectedRows;
        // Do something with the selected rows, e.g., update a property in your component
        this.updateRecords();
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get currentPageNumber(){
        return this.currentPage;
    }

    get totalPagesNumber(){
        return this.totalPages;
    }

    handleProcessSelected() {
        console.log('handleProcessSelected');
        const selectedRows = this.template.querySelector('c-custom-datatable').getSelectedRows();
        console.log(JSON.stringify(selectedRows));
        // Call the Apex method to process selected opportunities
        OpportunityRelatedListController.processSelectedOpportunities({ selectedOpportunities: selectedRows })
            .then(result => {
                // Handle the result as needed
            })
            .catch(error => {
                console.error('Error processing selected opportunities: ' + JSON.stringify(error));
            });
    }


    // Event to register the datatable lookup mark up.
    handleItemRegister(event) {
        event.stopPropagation(); //stops the window click to propagate to allow to register of markup.
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name))
            this.privateChildren[item.name] = {};
        this.privateChildren[item.name][item.guid] = item;
    }

    handleChange(event) {
        event.preventDefault();
        this.accountId = event.target.value;
        this.showSpinner = true;
    }

    handleCancel(event) {
        event.preventDefault();
        this.records = JSON.parse(JSON.stringify(this.lastSavedData));
        this.handleWindowOnclick('reset');
        this.draftValues = [];
    }

    handleCellChange(event) {
        event.preventDefault();
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    //Captures the changed lookup value and updates the records list variable.
    handleValueChange(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem;
        switch (dataRecieved.label) {
            case 'Account':
                updatedItem = {
                    Id: dataRecieved.context,
                    AccountId: dataRecieved.value
                };
                // Set the cell edit class to edited to mark it as value changed.
                this.setClassesOnData(
                    dataRecieved.context,
                    'accountNameClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            case 'Pricebook':
                updatedItem = {
                    Id: dataRecieved.context,
                    Pricebook2Id: dataRecieved.value
                };
                // Set the cell edit class to edited to mark it as value changed.
                this.setClassesOnData(
                    dataRecieved.context,
                    'priceBookNameClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        }
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.records));
        copyData.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        this.records = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    handleEdit(event) {
        event.preventDefault();
        let dataRecieved = event.detail.data;
        this.handleWindowOnclick(dataRecieved.context);
        switch (dataRecieved.label) {
            case 'Account':
                this.setClassesOnData(
                    dataRecieved.context,
                    'accountNameClass',
                    'slds-cell-edit'
                );
                break;
            case 'Pricebook':
                this.setClassesOnData(
                    dataRecieved.context,
                    'priceBookNameClass',
                    'slds-cell-edit'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        };
    }

    setClassesOnData(id, fieldName, fieldValue) {
        this.records = JSON.parse(JSON.stringify(this.records));
        this.records.forEach((detail) => {
            if (detail.Id === id) {
                detail[fieldName] = fieldValue;
            }
        });
    }

    handleSave(event) {
        event.preventDefault();
        this.showSpinner = true;
        // Update the draftvalues
        saveDraftValues({ data: this.draftValues })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunities updated successfully',
                        variant: 'success'
                    })
                );
                //Get the updated list with refreshApex.
                refreshApex(this.wiredRecords).then(() => {
                    this.records.forEach(record => {
                        record.accountNameClass = 'slds-cell-edit';
                    });
                    this.draftValues = [];
                });

                 // Clear selected rows after save
                 this.template.querySelector('c-custom-datatable').clearAllSelectedRows();
            })
            .catch(error => {
                console.log('error : ' + JSON.stringify(error));
                this.showSpinner = false;
            });
    }
}