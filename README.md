# PSFileAttachTemplate
THIS SOFTWARE IS COVERED BY [THIS DISCLAIMER](https://raw.githubusercontent.com/thedges/Disclaimer/master/disclaimer.txt).

This package contains a Lightning component for declaring a template to define required/optional files to attach to a target record. 

![alt text](https://github.com/thedges/PSFileAttachTemplate/blob/master/PSFileAttachTemplate.gif "PSFileAttachTemplate")

It provides following key functionality:
* <b>File Template</b> - create a template to define the required and optional files to allow user to attach to a record. The template utilizes the PSFileAttachTemplate and PSFileAttachDef custom objects. You can specify the following for each file to be attached:
   * <b>Filename</b> - the name to set at the title of the uploaded file
   * <b>Required</b> - set boolean if file is required
   * <b>Allowed Extensions</b> - the file extensions allowed for this document. Provide a comma separated value list like "jpg,png,pdf,zip". Leave blank if you will accept any document format.
   * <b>Description</b> - a description of the file to upload and any user instructions
   * <b>Online Template</b> - a URL to a document template that user can download to fill out and upload
   * <b>Upload Field</b> - the API name of field (checkbox) on target object that will get set to true when file is uploaded or false if file is deleted. This field can be used to trigger Process Builer flows for automating other tasks. For example, you could create workflow to trigger once all required files have been uploaded.
   * <b>Community Access</b> - a boolean field to set if community users should be able to view the file uploaded by internal user
   * <b>Review</b> - a boolean field to identify that this document should be reviewed. It will show "yellow" when document is first uploaded until a user clicks the "Document Reviewed" checkbox at bottom of the document card. The user name and datetime when the checkbox was clicked will be logged and displayed.
   * <b>Filter Field</b> - the field API name on the parent object that you want to filter documents by. This provides ability to show/hide documents based on a record field value. A good use case is to filter based on picklist field.
   * <b>Filter Values</b> - a comma-separated list of values that above filter field must match to show this document
   
* <b>Lightning Component</b> - a component that can be used on internal pages or community pages. Component provides a card based layout for your required/optional files to be attached. Uploaded files are highlighted in green, required files that have not been uploaded are highlighted in red, and optional files are highlighted in grey (but change to green when uploaded).

   Configuration options:
   * <b>Record ID</b> - __[ONLY SET THIS IF USED IN FLOW]__ this is record id to attach files to which should be variable passed in from Flow
   * <b>Template</b> - select the template to apply
   * <b>Show File Preview</b> - for uploaded files, show a preview of file in bottom of card that allows user to click in to it for more features

![alt text](https://github.com/thedges/PSFileAttachTemplate/blob/master/PSFileAttachTemplate-filePreview.png "File Preview Option")

   The card shows the following:
   * <b>Title</b> - the name of the file as defined in file definiton above. The file name is clickable once a file is uploaded.
   * <b>Description</b> - the description details as defined in the file definition above
   * <b>File Upload button</b> - section to upload file (either pick file on file system or drag-n-drop)
   * <b>File State</b> - for files that have been uploaded, the file stats: size, type, load date/time
   * <b>Template Icon</b> - icon that when clicked will take user to the online template defined in the file definition
   * <b>Delete Icon</b> - for an uploaded file, a delete icon to easily be able to delete file if needed


<b>Here are steps to use this component:</b>
  1. Install the component per the "Deploy to Salesforce" button below
  2. Setup users to have access to custom objects that drive the component. Either assign the permset "PSFileAttachTemplate" to your users  ...or... make sure users have read/write access to the PSFileAttachTemplate and PSFileAttachDef objects and PSFileAttachTemplate tab
  3. The default external org wide default for the PSCommFooterConfig object will default to 'Private'. Make sure to set to 'Public Read Only' else **the component will not show in community**.
  4. Next create a configuration to drive the component:
     * First navigate to the PSCommFooterConfig tab and create a record. Fill out all appropriate fields per above definitions.
     * If you are going to use the "Big" option, create child PSCommFooterTopics
       * For each PSCommFooterTopic created above, create 1..many PSCommFooterLink records
     * If you are going to use the "Default" or "Slim" options, create 1..many PSCommFooterPrimaryLink records
  5. For the template, create a list of file definitions for the files to attach to the record. Set the record fields (filename, required, description, etc...) as defined above
  6. Drop the PSFileAttachTemplate Lightning Component on an internal or community page. Configure the Lightning Component and select the appropriate template name you specified earlier.


<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

