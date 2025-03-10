({
  setFile: function (component, fileId) {
    console.log ('setFile invoked...');
    var self = this;
    var map = {};

    var fileDef = component.get ('v.fileDef');
    var recordId = component.get ('v.recordId');

    // save the case
    var action = component.get ('c.setFileApex');
    action.setParams ({
      recordId: recordId,
      fileId: fileId,
      fileName: fileDef.filename,
      bField: fileDef.uploadField,
      commAccess: fileDef.communityAccess,
      filenameImpl: fileDef.filenameImpl,
      keepFilename: fileDef.keepFilename
    });

    action.setCallback (this, function (actionResult) {
      var state = actionResult.getState ();
      if (state === 'SUCCESS') {
        $A.get ('e.c:PSFileAttachRefresh').fire ();
        $A.get ('e.force:refreshView').fire ();
      } else {
        self.handleErrors (component, actionResult.getError ());
      }
    });
    $A.enqueueAction (action);
  },
  deleteFile: function (component) {
    console.log ('deleteFile invoked...');

    var fileDef = component.get ('v.fileDef');
    var recordId = component.get ('v.recordId');

    var self = this;
    var map = {};

    // save the case
    var action = component.get ('c.deleteFileApex');
    action.setParams ({
      recordId: recordId,
      fileId: fileDef.attachId,
      bField: fileDef.uploadField,
    });

    action.setCallback (this, function (actionResult) {
      var state = actionResult.getState ();
      if (state === 'SUCCESS') {
        $A.get ('e.c:PSFileAttachRefresh').fire ();
        $A.get ('e.force:refreshView').fire ();
      } else {
        self.handleErrors (component, actionResult.getError ());
      }
    });
    $A.enqueueAction (action);
  },
  setFileReview: function (component, reviewedFlag) {
    console.log ('setFileReview invoked...');
    var self = this;
    var map = {};

    var fileDef = component.get ('v.fileDef');
    var recordId = component.get ('v.recordId');

    // save the case
    var action = component.get ('c.setReviewApex');
    action.setParams ({
      recordId: recordId,
      fileId: fileDef.attachId,
      reviewedFlag: reviewedFlag,
    });

    action.setCallback (this, function (actionResult) {
      var state = actionResult.getState ();
      if (state === 'SUCCESS') {
		var resp = actionResult.getReturnValue();
		console.log(JSON.stringify(resp));
		var revInfo = JSON.parse(resp);

		var fileDef = component.get ('v.fileDef');
		fileDef.reviewed = reviewedFlag;
        fileDef.reviewerName = revInfo.reviewerName;
		fileDef.reviewerDate = revInfo.reviewerDate;
        component.set ('v.fileDef', fileDef);

        self.setBackgroundColor (component);
      } else {
        self.handleErrors (component, actionResult.getError ());
      }
    });
    $A.enqueueAction (action);
  },
  setBackgroundColor: function (component) {
    var fileDef = component.get ('v.fileDef');

    if (fileDef.required && !fileDef.uploaded) {
      document.getElementById (fileDef.id).style.backgroundColor = '#ecc6c6'; // pale red
    } else if (fileDef.uploaded && !fileDef.reviewOption) {
      document.getElementById (fileDef.id).style.backgroundColor = '#b3e6b3'; // pale green
    } else if (fileDef.uploaded && fileDef.reviewOption && fileDef.reviewed) {
      document.getElementById (fileDef.id).style.backgroundColor = '#b3e6b3'; // pale green
    } else if (fileDef.uploaded && fileDef.reviewOption && !fileDef.reviewed) {
      document.getElementById (fileDef.id).style.backgroundColor = '#fafad2'; // pale yellow
    } else {
      document.getElementById (fileDef.id).style.backgroundColor = '#f2f2f2'; // silver/grey
    }
  },
  handleErrors: function (component, errors) {
    // Configure error toast
    let toastParams = {
      title: 'Error!',
      message: 'Unknown error', // Default error message
      type: 'error',
      mode: 'sticky',
    };
    // Pass the error message if any
    if (errors && Array.isArray (errors) && errors.length > 0) {
      toastParams.message = errors[0].message;
    } else {
      //toastParams.message = errors;
    }
    // Fire error toast
    let toastEvent = $A.get ('e.force:showToast');
    toastEvent.setParams (toastParams);
    toastEvent.fire ();
  },
});