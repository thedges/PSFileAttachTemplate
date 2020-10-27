import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class PsFileAttachEntry2
  extends NavigationMixin (LightningElement) {
  @api fileDef;
  @track showDelete = false;

  handleEnter () {
    this.showDelete = true;
  }

  handleLeave () {
    this.showDelete = false;
  }

  handleClick () {
    console.log ('clicked row...');
    this[NavigationMixin.Navigate] ({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.fileDef.id,
        actionName: 'view',
      },
    });
  }

  deleteFile () {
    console.log ('delete file...');
    this.dispatchEvent (
      new CustomEvent ('delete', {
        detail: this.fileDef.id
      })
    );
  }

  get icon () {
    var fileType = 'unknown';

    switch (this.fileDef.uploadType) {
      case 'JPG':
      case 'PNG':
      case 'GIF':
      case 'JPEG':
        fileType = 'image';
        break;
      default:
        fileType = this.fileDef.uploadType.toLowerCase ();
        break;
    }

    return 'doctype:' + fileType;
  }
}