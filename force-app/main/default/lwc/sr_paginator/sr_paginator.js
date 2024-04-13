import { LightningElement, api } from 'lwc';

export default class Sr_paginator extends LightningElement {

    @api totalCount;
    @api rowsPerPage;
    @api currentPageNumber;

    get totalPages(){
        const fullPages =  Math.floor(this.totalCount / this.rowsPerPage);
        const hasPartialPage = (this.totalCount % this.rowsPerPage) > 0;
        return fullPages + (hasPartialPage ? 1 : 0);
    }

    get pageOptions(){

        let result = [];
        for(let i = 1; i <= this.totalPages; i++){
            result.push({
                label: i.toString(),
                value: i
            });
        }

        return result;
    }

    get hasFirst(){
        return this.currentPageNumber != 1;
    }

    get hasLast(){
        return this.currentPageNumber != this.totalPages && this.totalPages;
    }

    get hasPrev(){
        return this.currentPageNumber >= 2;
    }

    get hasNext(){
        return this.currentPageNumber <= (this.totalPages - 1);
    }

    first(event){
        this.notifyPageChange(1);
    }

    last(event){
        this.notifyPageChange(this.totalPages);
    }

    next(event){
        this.notifyPageChange(++this.currentPageNumber);
    }

    previous(event){
        this.notifyPageChange(--this.currentPageNumber);
    }

    handleChange(event){
        this.notifyPageChange(Number.parseInt(event.target.value));
    }

    notifyPageChange(newPageNumber){
        this.dispatchEvent(new CustomEvent('pagechange', {
            detail: newPageNumber
        }));
    }
}