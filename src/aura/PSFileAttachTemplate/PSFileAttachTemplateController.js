({
	doInit : function(component, event, helper) {
		console.log('PSFileAttachTemplateController::doInit...');
		helper.getFileDefs(component);
	}
})