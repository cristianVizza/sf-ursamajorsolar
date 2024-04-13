import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getFieldDisplayValue } from "lightning/uiRecordApi";

export default class Sr_reconfigureRowCell extends LightningElement {

    _column;
    @api item;
    @api set column(val){
        this._column = JSON.parse(JSON.stringify(val));
        this.mergeFieldDescribeIntoColumn();
    }

    get column(){

        this.mergeFieldDescribeIntoColumn();
        return this._column;
    }

    productDescribe;
    
    product;
    fieldApiName;

    hasMerged = false;

    @wire(getObjectInfo, { objectApiName: 'Product2' })
    productDescribe({error,data}){

        if(data){
            this.productDescribe = data;
            this.mergeFieldDescribeIntoColumn();
        }
    }

    mergeFieldDescribeIntoColumn(){

        if(this._column && this.productDescribe && this.hasMerged == false){

            if(this.productDescribe.fields.hasOwnProperty(this._column.SR_Product2_Field_API_Name__c)){
                
                this._column.fieldDescribe = this.productDescribe.fields[this._column.SR_Product2_Field_API_Name__c];
            }
            else {
                throw new Error('Unsupported Product2 field[\'' + col.SR_Product2_Field_API_Name__c +'\']');
            }

            this.hasMerged = true;
        }
    }

    connectedCallback(){
        
        this.fieldApiName = this.column.SR_Product2_Field_API_Name__c;

        switch(this.item.polymorphicWorkaround){

            case 'Product2' : {
                this.product = this.item.record;
                break;
            }

            case 'SR_ProductOption__c' : {

                this.product = this.item.record.SR_Optional_SKU__r;
                break;
            }
        }
    }

    get fieldDataType(){
        
        this.mergeFieldDescribeIntoColumn();

        if(this.column?.fieldDescribe?.dataType){
            return this.column.fieldDescribe.dataType;
        }
    }

    get displayValue(){
        if(this.product && this.fieldApiName){
            return JSON.stringify(this.column, null, 4);
        }
    }

    get isDateField(){
        return this.fieldDataType === 'Date';
    }

    get isTextField(){

        const textTypes = [
            'Picklist',
            'MultiPicklist',
            'String',
            'TextArea'
        ];
        
        return textTypes.indexOf(this.fieldDataType) >= 0;
    }

    get debug(){
        const textTypes = [
            'Picklist',
            'MultiPicklist',
            'String',
            'TextArea'
        ];

        return textTypes.indexOf(this.fieldDataType);
    }

    get fieldValue(){

        if(this.product && this.fieldApiName){
            return this.product[this.fieldApiName];
        }
    }

    // "dataType": "Date",
    // "dataType": "Picklist",

    // "dataType": "Boolean",
    // "dataType": "Currency",
    // "dataType": "DateTime",
    // "dataType": "Double",
    // "dataType": "MultiPicklist",
    // "dataType": "Percent",
    // "dataType": "Reference",
    // "dataType": "String",
    // "dataType": "TextArea",
    // "dataType": "Url",




}