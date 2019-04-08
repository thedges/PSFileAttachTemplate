({
	setFile: function (component, fileId) {
		console.log('setFile invoked...');
		var self = this;
		var map = {};

		var fileDef = component.get("v.fileDef");
		var recordId = component.get("v.recordId");

		// save the case
		var action = component.get("c.setFile");
		action.setParams({
			"recordId": recordId,
			"fileId": fileId,
			"fileName": fileDef.filename,
			"bField": fileDef.uploadField,
			"commAccess": fileDef.communityAccess
		});

		action.setCallback(this, function (actionResult) {
			var state = actionResult.getState();
			if (state === "SUCCESS") {
				console.log('1');
				var resp = actionResult.getReturnValue();
				//console.log(JSON.stringify(resp));

				$A.get("e.c:PSFileAttachRefresh").fire();
				console.log('2');
				//component.getEvent("refreshEvent").fire();
				$A.get('e.force:refreshView').fire();
				console.log('3');

			} else {
				self.handleErrors(component, actionResult.getError());
			}

		});
		$A.enqueueAction(action);
	},
	deleteFile: function (component) {
		console.log('deleteFile invoked...');

		var fileDef = component.get("v.fileDef");
		var recordId = component.get("v.recordId");

		var self = this;
		var map = {};

		// save the case
		var action = component.get("c.deleteFile");
		action.setParams({
			"recordId": recordId,
			"fileId": fileDef.attachId,
			"bField": fileDef.uploadField
		});

		action.setCallback(this, function (actionResult) {
			var state = actionResult.getState();
			if (state === "SUCCESS") {
				$A.get("e.c:PSFileAttachRefresh").fire();
				//component.getEvent("refreshEvent").fire();
				$A.get('e.force:refreshView').fire();

			} else {
				self.handleErrors(component, actionResult.getError());
			}

		});
		$A.enqueueAction(action);
	},
	handleErrors: function (component, errors) {
		// Configure error toast
		let toastParams = {
			title: "Error!",
			message: "Unknown error", // Default error message
			type: "error",
			mode: "sticky"
		};
		// Pass the error message if any
		if (errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		else
		{
			//toastParams.message = errors;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();

	}
})