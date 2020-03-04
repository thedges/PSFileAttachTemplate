({
	onRender : function(component, event, helper) {
		helper.setBackgroundColor(component);
	},
	handleUploadFinished : function(component, event, helper) {
		console.log('handleUploadFinished...');
		var fileDef = component.get("v.fileDef");
		var recordId = component.get("v.recordId");

		var id = event.getSource().get('v.name');

		var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
		var fileName = uploadedFiles[0].name;
		
		//var newfileName = helper.getFilenameById(component, id);
		//console.log('newfileName=' + newfileName);
		helper.setFile(component, documentId);
		
		/*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "File " + fileName + " (" + documentId + " ) Uploaded successfully."
        });
		toastEvent.fire();
		*/
	},
	handleReviewCheck : function(component, event, helper) {
		console.log('handleReviewCheck...');

		var fileDef = component.get("v.fileDef");

		console.log('fileDef1=' + JSON.stringify(fileDef));
		fileDef.reviewed = !fileDef.reviewed;
		console.log('fileDef2=' + JSON.stringify(fileDef));
		component.set("v.fileDef", fileDef);

		helper.setFileReview(component, fileDef.reviewed);

    },
	handleDeleteAttachment : function(component, event, helper) {
		console.log('handleDeleteAttachment...');
		helper.deleteFile(component);
	},
	handleViewAttachment: function(component, event, helper) {
		console.log('handleViewAttachment...');
		var sObjectEvent = $A.get("e.force:navigateToSObject");

        sObjectEvent.setParams({
            "recordId": component.get("v.fileDef.attachId")
        })

        sObjectEvent.fire();

	}
})