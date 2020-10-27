import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getFileDefs from '@salesforce/apex/PSFileAttachTemplateController2.getFileDefs';

export default class PsFileAttachTemplate2 extends LightningElement {
  @api recordId;
  @api templateDefId;
  fileDefs;

  connectedCallback() {
    var self = this;

    getFileDefs({templateDefId: this.templateDefId, recordId: this.recordId})
    .then(result => {
       console.log('lwc_result=' + JSON.stringify(result));
       self.fileDefs = result;
       //self.config = JSON.parse(result);
    })
    .catch (error => {
       self.handleError(error);
    });
}

handleError (err) {
    console.log ('error=' + err);
    console.log ('type=' + typeof err);

    this.showSpinner = false;

    const event = new ShowToastEvent ({
      title: err.statusText,
      message: err.body.message,
      variant: 'error',
      mode: 'pester',
    });
    this.dispatchEvent (event);
  }
}