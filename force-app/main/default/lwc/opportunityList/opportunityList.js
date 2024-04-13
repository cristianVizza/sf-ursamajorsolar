import { LightningElement, wire, track } from 'lwc';
import getOpportunities from '@salesforce/apex/OpportunityController.getOpportunities';


const COLUMNS = [
    { label: 'Select', type: 'boolean', fieldName: 'isSelected', editable: true },
    { label: 'Opportunity Name', fieldName: 'Name', type: 'text' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency', typeAttributes: { currencyCode: 'USD'} },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
    { label: 'Stage', fieldName: 'StageName', type: 'text' },
    { label: 'Description', fieldName: 'Description', type: 'text', editable: true }
];

export default class OpportunityList extends LightningElement {

    columns = COLUMNS;
    // Add the following properties
    opportunities = [];
    displayedOpportunities = [];
    currentPage = 1;
    pageSize = 10;
    totalPages = 0;
    sortedBy;
    sortedDirection;

    // Add the following methods
    connectedCallback() {
        this.updatePageData();
    }

    updatePageData() {
        // Logic to update the data based on current page and page size
        const startIndex = (this.currentPage - 1) * this.pageSize;
        this.displayedOpportunities = this.opportunities.slice(startIndex, startIndex + this.pageSize);
        this.totalPages = Math.ceil(this.opportunities.length / this.pageSize);
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        // Implement logic to sort the data
        this.updatePageData();
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updatePageData();
        }
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePageData();
        }
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    // Wired method to retrieve opportunities
    @wire(getOpportunities)
    wiredOpportunities({ error, data }) {
        if (data) {
            this.opportunities = data;
            console.log('wire');
            console.log(this.opportunities);
            this.updatePageData();
        } else if (error) {
            console.error(error);
        }
    }
}