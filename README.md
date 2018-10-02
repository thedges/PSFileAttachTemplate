# PSFileAttachTemplate
This package contains a Lightning component for declaring a template to define required/optional files to attach to a target record. I provides following key functionality:
* <b>File Template</b> - create a template to define the required and optional files to allow user to attach to a record. 
* <b>Lightning Component</b> - a component that can be used on internal pages or community pages. Component provides a card based layout for your required files. Uploaded files are highlighted in green, required files that have not been uploaded are highlighted in red, and optional files are highlighted in grey (but change to green when uploaded)
   * <b>Verify</b> - a verification screen of information about to be submited
   * <b>Confirmation</b> - screen confirming submission of service case with link to new case record

<b>Dependency:</b> Install the [PSCommon](https://github.com/thedges/PSCommon) package first

![alt text](https://github.com/thedges/PS311ServiceRequest/blob/master/311-community.png "Sample Image")

* The component configuration fields are:
  - <b>Auto Center</b> - a flag to set whether the map auto-centers on current GPS location or use the default lat/lng below
  - <b>Map Center Latitude</b> - the default latitude value for centering the map
  - <b>Map Center Latitude</b> - the default longitude value for centering the map
  - <b>Map Zoom Level</b> - the default map zoom level; default: 11
  - <b>Full Address Field</b> - the field API name for storing the full address string (street, city, state, postal)
  - <b>Street Field</b> - the field API name for storing the street
  - <b>City Field</b> - the field API name for storing the city
  - <b>State Field</b> - the field API name for storing the state
  - <b>Zipcode Field</b> - the field API name for storing the zipcode/postal code
  - <b>Record Type</b> - a drop-down list of Case record types; select one to filter Type field values and to set record type on new case creation
  - <b>My Domain</b> - if a record type is selected above, provide your My Domain value as shown in the example picture below.

![alt text](https://github.com/thedges/PS311ServiceRequest/blob/master/mydomain.png "My Domain")

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

