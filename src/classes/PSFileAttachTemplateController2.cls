public class PSFileAttachTemplateController2 {

    @AuraEnabled
    public static List<FileDef> getFileDefs(String templateDefId, String recordId)
    {
        System.debug('getFileDefs...');
        System.debug('templateDefId = ' + templateDefId);
        System.debug('recordId = ' + recordId);

        try {

            ////////////////////////////////
            // query all file definitions //
            ////////////////////////////////
            List<FileDef> fileDefList = new List<FileDef>();
            for (PSFileAttachDef__c t : [SELECT Id, Filename__c, Allowed_Extensions__c, Description__c, Online_Template__c,
                                                Required__c, Upload_Field__c, Community_Access__c,
                                                Filter_Field__c, Filter_Values__c, Review__c, Order__c, Minimum__c, Keep_Filename__c
                                                FROM PSFileAttachDef__c
                                                WHERE (PSFileAttachTemplate__c = :templateDefId OR PSFileAttachTemplate__r.Template_Name__c = :templateDefId)
                                                ORDER BY Order__c ASC])
            {
                FileDef fd = new FileDef();
                fd.id = t.id;
                fd.filename = t.Filename__c;
                fd.allowedExtensions = parseExtensions(t.Allowed_Extensions__c);
                fd.description = t.Description__c;
                fd.onlineTemplateURL = t.Online_Template__c;
                fd.required = t.Required__c;
                fd.uploadField = t.Upload_Field__c;
                fd.communityAccess = t.Community_Access__c;

                if (t.Order__c != null) fd.order = t.Order__c.intValue();
                if (t.Minimum__c != null) fd.minimum = t.Minimum__c.intValue();
                fd.keepFilename = t.Keep_Filename__c;
                fileDefList.add(fd);
            }


            ///////////////////////////
            // get content documents //
            ///////////////////////////

            List<ContentDocumentLink> cdlList = [SELECT Id,  LinkedEntityId, ShareType, SystemModstamp, Visibility,
                                                        ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.FileExtension,
                                                        ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.Id, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.PSFileAttachDefID__c
                                                        FROM ContentDocumentLink
                                                        WHERE linkedentityid = :recordId AND IsDeleted=false];

            for (FileDef fd : fileDefList)
            {
                for (ContentDocumentLink cdl : cdlList)
                {
                    if (fd.id == cdl.ContentDocument.LatestPublishedVersion.PSFileAttachDefID__c)
                    {

                        if (fd.fileList == null) fd.fileList = new List<FileEntry>();

                        FileEntry fe = new FileEntry();

                        fe.id = cdl.ContentDocument.Id;
                        fe.versionId = cdl.ContentDocument.LatestPublishedVersionId;
                        fe.filename = cdl.ContentDocument.Title;

                        fe.uploaded = true;
                        fe.uploadDttm = cdl.ContentDocument.LastModifiedDate.format();
                        fe.uploadSize = cdl.ContentDocument.ContentSize;
                        fe.uploadType = cdl.ContentDocument.FileType;

                        fd.fileList.add(fe);
                    }
                }
            }


            return fileDefList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<FileEntry> tagFiles(String recordId, String templateDefId, String fileName, Boolean keepFilename,
                                           Boolean communityAccess, String bField, Boolean required, Integer minimum, String files)
    {
        //////////////////////////////////////////////////////////////////////////////
        // tag files to associate to correct PSFileAttachDef section                //
        // - this sets the PSFileAttachDefID__c filed on the content version record //
        //////////////////////////////////////////////////////////////////////////////
        List<FileUpload> uploads = (List<FileUpload>)JSON.deserialize(files, List<FileUpload>.class);
        System.debug(' > uploads = ' + JSON.serializePretty(uploads));

        List<Id> contentDocIds = new List<Id>();
        for (FileUpload fu : uploads)
        {
            contentDocIds.add(fu.documentId);
        }

        List<ContentDocument> contentDocList = [SELECT Id, FileType, FileExtension, ContentSize, CreatedDate, Title,
                                                       Description, LatestPublishedVersionId
                                                       FROM ContentDocument
                                                       WHERE Id IN :contentDocIds];

        List<ContentVersion> contentVerList = new List<ContentVersion>();
        for (ContentDocument cd : contentDocList)
        {
            ContentVersion cv = new ContentVersion();
            cv.Id = cd.LatestPublishedVersionId;
            cv.PSFileAttachDefID__c = templateDefId;
            contentVerList.add(cv);
        }


        update contentVerList;



        //////////////////////////////////////////
        // update document for community access //
        //////////////////////////////////////////
        if (communityAccess)
        {
            List<ContentDocumentLink> cdlList = [SELECT Id, ShareType, Visibility
                                                        FROM ContentDocumentLink
                                                        WHERE ContentDocumentId IN :contentDocIds
                                                        AND LinkedEntityId = :recordId
                                                         AND Visibility != 'AllUsers'];
            if (cdlList != null && cdlList.size() > 0)
            {
                for (ContentDocumentLink cdl : cdlList)
                {
                    cdl.Visibility = 'AllUsers';
                }
                update cdlList;
            }
        }

        List<FileEntry> resp = new List<FileEntry>();

        ////////////////////////////////////////////////////////////
        // return list of all files for that PSFileAttachDefID__c //
        ////////////////////////////////////////////////////////////
        List<ContentDocumentLink> cdlList = [SELECT Id,  LinkedEntityId, ShareType, SystemModstamp, Visibility,
                                                    ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.FileExtension,
                                                    ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.Id, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.PSFileAttachDefID__c
                                                    FROM ContentDocumentLink
                                                    WHERE linkedentityid = :recordId AND IsDeleted=false];


        for (ContentDocumentLink cdl : cdlList)
        {
            if (cdl.ContentDocument.LatestPublishedVersion.PSFileAttachDefID__c == templateDefId)
            {
                FileEntry fe = new FileEntry();

                fe.id = cdl.ContentDocument.Id;
                fe.versionId = cdl.ContentDocument.LatestPublishedVersionId;
                fe.filename = cdl.ContentDocument.Title;

                fe.uploaded = true;
                fe.uploadDttm = cdl.ContentDocument.LastModifiedDate.format();
                fe.uploadSize = cdl.ContentDocument.ContentSize;
                fe.uploadType = cdl.ContentDocument.FileType;

                resp.add(fe);
            }
        }

        //////////////////////////////////////////
        // set record field boolean if provided //
        //////////////////////////////////////////
        System.debug('bField = ' + bField);
        System.debug('minimum = ' + minimum);
        System.debug('resp.size() = ' + resp.size());
        if (bField != null)
        {
            System.debug('setting bField...');
            Boolean bval = false;
            if (minimum != null && resp != null && resp.size() >= minimum)
            {
                System.debug('1');
                bval = true;
            }
            else if (minimum == null && resp != null && resp.size() > 0) {
                System.debug('2');
                bval = true;
            }

            System.debug('3');
            Id tmpRecId = recordId;
            SObject obj = tmpRecId.getSObjectType().newSObject(tmpRecId);
            obj.put(bField, bval);
            update obj;
            System.debug('4');
        }

        return resp;

    }

    @AuraEnabled
    public static List<FileEntry> deleteFile(String recordId, String documentId, String templateDefId, String bField, Boolean required, Integer minimum)
    {
        try
        {
            ContentDocument cd = new ContentDocument();
            cd.id = documentId;
            delete cd;

            List<FileEntry> resp = new List<FileEntry>();

            ////////////////////////////////////////////////////////////
            // return list of all files for that PSFileAttachDefID__c //
            ////////////////////////////////////////////////////////////
            List<ContentDocumentLink> cdlList = [SELECT Id,  LinkedEntityId, ShareType, SystemModstamp, Visibility,
                                                        ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.FileExtension,
                                                        ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.Id, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.PSFileAttachDefID__c
                                                        FROM ContentDocumentLink
                                                        WHERE linkedentityid = :recordId AND IsDeleted=false];


            for (ContentDocumentLink cdl : cdlList)
            {
                if (cdl.ContentDocument.LatestPublishedVersion.PSFileAttachDefID__c == templateDefId)
                {
                    FileEntry fe = new FileEntry();

                    fe.id = cdl.ContentDocument.Id;
                    fe.versionId = cdl.ContentDocument.LatestPublishedVersionId;
                    fe.filename = cdl.ContentDocument.Title;

                    fe.uploaded = true;
                    fe.uploadDttm = cdl.ContentDocument.LastModifiedDate.format();
                    fe.uploadSize = cdl.ContentDocument.ContentSize;
                    fe.uploadType = cdl.ContentDocument.FileType;

                    resp.add(fe);
                }
            }


            /*
            ////////////////////////////////////////////////////////////
            // return list of all files for that PSFileAttachDefID__c //
            ////////////////////////////////////////////////////////////
            for (ContentVersion cv : [SELECT Id, ContentDocumentId, FileType, ContentSize, FileExtension, Title, LastModifiedDate
                                             FROM ContentVersion
                                             WHERE PSFileAttachDefID__c = :templateDefId
                                              ORDER BY LastModifiedDate ASC])
            {
                FileEntry fe = new FileEntry();
                fe.id = cv.ContentDocumentId;
                fe.versionId = cv.Id;
                fe.filename = cv.Title;
                fe.uploaded = true;
                fe.uploadDttm = cv.LastModifiedDate.format();
                fe.uploadSize = cv.ContentSize;
                fe.uploadType = cv.FileType;
                resp.add(fe);
            }
            */

            //////////////////////////////////////////
            // set record field boolean if provided //
            //////////////////////////////////////////
            if (bField != null)
            {
                Boolean bval = false;
                if (minimum != null && resp.size() >= minimum)
                {
                    bval = true;
                }
                else if (minimum == null && resp.size() > 0) {
                    bval = true;
                }

                Id tmpRecId = recordId;
                SObject obj = tmpRecId.getSObjectType().newSObject(tmpRecId);
                obj.put(bField, bval);
                update obj;
            }

            return resp;
        }
        catch (DMLException de)
        {
            String err;
            if (de.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY'))
            {
                err = 'Your user account does not have correct privileges to delete this file!';
            }
            else {
                err = de.getTypeName() + ' - ' + de.getMessage() + ' [Line: ' + de.getLineNumber() + ']';

            }
            System.debug(err);
            throw new  AuraHandledException(err);
        }
        catch (Exception e)
        {
            String err = e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']';
            System.debug(err);
            throw new  AuraHandledException(err);
        }
    }

    public static List<String> parseCSVString(String str)
    {
        return parseDelimitedString(str, ',');
    }

    public static List<String> parseDelimitedString(String str, String delim)
    {
        List<String> optList = new List<String>();
        for (String key : str.split(delim))
        {
            optList.add(key.trim());
        }

        return optList;
    }

    private static String convListToCSV(List<String> lst)
    {
        String csvStr;
        for(String str : lst)
        {
            if (csvStr == null)
            {
                csvStr = str;
            }
            else {
                csvStr += ',' + str;
            }
        }

        return csvStr;
    }


    private static String parseExtensions(String ext)
    {
        String retStr = null;

        if (ext == null || ext.length() == 0)
        {
            return null;
        }

        if (ext.contains(','))
        {
            List<String> strList = ext.split(',');
            for (String s : strList)
            {
                s = s.trim();
                if (retStr != null)
                {
                    retStr += ', .' + s.toLowerCase() + ', .' + s.toUpperCase();
                }
                else
                {
                    retStr = '.' + s.toLowerCase() + ', .' + s.toUpperCase();
                }
            }
        }
        else {
            ext = ext.trim();
            retStr = '.' + ext.toLowerCase() + ', .' + ext.toUpperCase();
        }
        return retStr;

    }

    public static Object getSobjectValue(SObject obj, String fieldname)
    {
        Object retVal;

        if (fieldname.indexOf('.') != -1)
        {
            List<String> flds = fieldname.split('\\.');
            Integer i=1;

            for (String fld : flds)
            {
                if (obj == null) return null;

                if (i++ == flds.size())
                {
                    retVal = obj.get(fld);
                }
                else {
                    obj = (SObject)obj.getSObject(fld);
                }
            }

        }
        else {
            retVal = obj.get(fieldname);
        }

        return retVal;
    }

    public class FileDef
    {
        @AuraEnabled public String id;
        @AuraEnabled public String filename;
        @AuraEnabled public String allowedExtensions;
        @AuraEnabled public String description;
        @AuraEnabled public String onlineTemplateURL;
        @AuraEnabled public Boolean required = false;
        @AuraEnabled public String uploadField;
        @AuraEnabled public Boolean communityAccess = false;
        @AuraEnabled public Boolean reviewOption = false;
        @AuraEnabled public Integer order = null;
        @AuraEnabled public Integer minimum = null;
        @AuraEnabled public Boolean keepFilename = false;

        @AuraEnabled public List<FileEntry> fileList = new List<FileEntry>();
    }

    public class FileEntry
    {
        @AuraEnabled public String id;                   // the ContentDocument Id
        @AuraEnabled public String versionId;
        @AuraEnabled public String filename;

        @AuraEnabled public Boolean uploaded = false;
        @AuraEnabled public String uploadDttm;
        @AuraEnabled public Integer uploadSize;
        @AuraEnabled public String uploadType;
    }

    public class FileUpload
    {
        public String name;
        public String documentId;
    }

}