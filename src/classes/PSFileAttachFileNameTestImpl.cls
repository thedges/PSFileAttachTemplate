public with sharing class PSFileAttachFileNameTestImpl implements PSFileAttachTemplateFileNamingInterface {
    public String getFilename(String recordId, String defaultName) {
        System.debug('called PSFileAttachFileNameTestImpl...');

        if (recordId.startsWith('003')) // only do special naming on Contact records
        {
            Contact con = [SELECT Id,  FirstName, LastName
            FROM Contact
            WHERE id = :recordId];

            return con.Firstname.left(1) + ' ' + con.LastName + '-' + defaultName;
        }
        return defaultName;  
    }
}