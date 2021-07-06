import { LightningElement,track,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getMetadata from '@salesforce/apex/MetadataController.getMetadata';
export const COLUMNS_DEFINITION = [
   {
        type: 'text',
        fieldName: 'MetadataComponentName',
        label: 'Metadata Name',
        initialWidth: 300,
    },
    {
        type: 'text',
        fieldName: 'RefMetadataComponentType',
        label: 'Ref Metadata Type',
    },
    {
        type: 'text',
        fieldName: 'RefMetadataComponentName',
        label: 'Reference Metadata Name',
    },
];

export default class Dependencynfo extends LightningElement {
    @track gridData= [];
    @track columns=COLUMNS_DEFINITION;
    error;
    @api searchKey = '';

    @wire(getMetadata,{searchKey: '$searchKey'})
    wiredObject({ error, data }) {
        if (data) {
            var result=[];
            data.forEach(child => {
                var ch=JSON.parse(JSON.stringify(child));
                if(ch.children!==undefined && ch.children.length>0)
                {
                    ch._children=ch.children;
                }
                ch.children=null;
                result.push(ch);
            });
            this.gridData=result;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
        
    }
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        return refreshApex(this.result);
    }
    handleFileDownload(event)
    {
        if(this.gridData!==undefined)
        {
            let csvContent = "data:text/csv;charset=utf-8,";
            
            this.gridData.forEach(function(rowArray) {
                let row = rowArray.MetadataComponentName+","+rowArray.RefMetadataComponentType+","+rowArray.RefMetadataComponentName+",";
                console.log(rowArray._children);
                if(rowArray._children!==undefined)
                { 
                    rowArray._children.forEach(function(child) {
                        csvContent += row + "\r\n";
                        row = child.MetadataComponentName+","+child.RefMetadataComponentType+","+child.RefMetadataComponentName+",";
                    });
                }
                csvContent += row + "\r\n";
            });
            var encodedUri = encodeURI(csvContent);
            var link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", "File.csv");
            document.body.appendChild(link); 
            link.click();
        }
    }
}


