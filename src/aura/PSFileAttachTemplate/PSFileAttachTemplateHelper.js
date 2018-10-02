({
	getFileDefs: function (component) {
		console.log('getFileDefs invoked...');
		var self = this;
		var map = {};

		// save the case
		var action = component.get("c.getFileDefs");
		action.setParams({
			"templateDefId": component.get("v.templateDefId"),
			"recordId": component.get("v.recordId")
		});

		action.setCallback(this, function (actionResult) {
			var state = actionResult.getState();
			if (state === "SUCCESS") {
				var resp = actionResult.getReturnValue();

				console.log(JSON.stringify(resp));
				component.set('v.fileDefs', resp);
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