({
	doInit : function(component, event, helper) {
		console.log('PSFileAttachTemplateController::doInit...');
		helper.getFileDefs(component);
	},
	handleRecordUpdated: function (component, event, helper) {
		console.log('PSFileAttachTemplateController::handleRecordUpdated...');
		helper.getFileDefs(component);
	}
})