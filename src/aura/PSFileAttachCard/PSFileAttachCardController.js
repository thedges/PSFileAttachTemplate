({
	onRender : function(component, event, helper) {
		var fileDef = component.get("v.fileDef");

		if (fileDef.required && !fileDef.uploaded)
		{
		  document.getElementById(fileDef.id).style.backgroundColor = "#ecc6c6";
		}
		else if (fileDef.uploaded)
		{
		  document.getElementById(fileDef.id).style.backgroundColor = "#b3e6b3";
		}
		else
		{
		  document.getElementById(fileDef.id).style.backgroundColor = "#f2f2f2";
		}
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