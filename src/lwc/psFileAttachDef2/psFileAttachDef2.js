import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import tagFiles
  from '@salesforce/apex/PSFileAttachTemplateController2.tagFiles';
import deleteFile
  from '@salesforce/apex/PSFileAttachTemplateController2.deleteFile';

export default class PsFileAttachDef2 extends LightningElement {
  @api fileDef;
  @api recordId;

  @track localFileDef = null;
  @track showFileUpload = false;

  get iconName () {
    if (this.localFileDef.required) {
      if (
        this.localFileDef.minimum == null &&
        this.localFileDef.fileList.length > 0
      ) {
        return 'action:approval';
      } else if (
        this.localFileDef.minimum != null &&
        this.localFileDef.fileList.length >= this.localFileDef.minimum
      ) {
        return 'action:approval';
      } else {
        return 'action:close';
      }
    }
    else
    {
        return 'action:info';
    }
  }

  connectedCallback () {
    this.localFileDef = JSON.parse (JSON.stringify (this.fileDef));

    var i = 1;
    this.localFileDef.fileList.forEach (ele => {
      ele.idx = i++;
    });
  }

  handleUploadFinished (event) {
    var self = this;

    const uploadedFiles = event.detail.files;

    console.log (JSON.stringify (uploadedFiles));

    tagFiles ({
      recordId: this.recordId,
      templateDefId: this.localFileDef.id,
      fileName: this.localFileDef.fileName,
      keepFilename: this.localFileDef.keepFilename,
      communityAccess: this.localFileDef.communityAccess,
      bField: this.localFileDef.uploadField,
      required: this.localFileDef.required,
      minimum: this.localFileDef.minimum, 
      files: JSON.stringify (uploadedFiles),
    }).then (result => {
      console.log ('files have been tagged!');
      console.log('files =' + JSON.stringify(result));
      self.localFileDef.fileList = result;
    });

    this.showFileUpload = false;
  }

  handleDeleteFileEvent(event) {
    var self = this;

    deleteFile ({
      recordId: this.recordId,
      documentId: event.detail,
      templateDefId: this.localFileDef.id,
      bField: this.localFileDef.uploadField,
      required: this.localFileDef.required,
      minimum: this.localFileDef.minimum
    }).then (result => {
      console.log('removing file from list...');
       for (let i = 0; i < self.localFileDef.fileList.length; i++)
       {
        console.log('i=' + i);
         let f = self.localFileDef.fileList[i];
         console.log('f=' + JSON.stringify(f));
         if (f.id == event.detail)
         {
          console.log('removing file');
           self.localFileDef.fileList.splice(i, 1);
         }
       }
    })
    .catch(err => {
      this.handleError(err);
    });

  }

  addFile () {
    console.log ('addFile clicked...');
    this.showFileUpload = true;
  }

  removeFile () {
    console.log ('removeFile clicked...');
    this.showFileUpload = false;
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