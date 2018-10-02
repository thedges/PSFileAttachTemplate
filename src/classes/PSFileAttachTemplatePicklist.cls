global class PSFileAttachTemplatePicklist extends VisualEditor.DynamicPickList{
        global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
       
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        
        for (PSFileAttachTemplate__c t : [SELECT Id, Template_Name__c FROM PSFileAttachTemplate__c ORDER BY Template_Name__c ASC])
        {
            VisualEditor.DataRow value1 = new VisualEditor.DataRow(t.Template_Name__c, '' + t.Id);
            myValues.addRow(value1);
        }
        
        return myValues;
    }
}