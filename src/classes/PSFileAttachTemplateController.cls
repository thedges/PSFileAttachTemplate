public class PSFileAttachTemplateController {

    @AuraEnabled
    public static List<FileDef> getFileDefs(String templateDefId, String recordId)
    {
        System.debug('getTemplateDef...');

        try {

            ////////////////////////////////
            // query all file definitions //
            ////////////////////////////////
            List<FileDef> fileDefList = new List<FileDef>();
            for (PSFileAttachDef__c t : [SELECT Id, Filename__c, Filename_Interface_Impl__c, Allowed_Extensions__c, Description__c, Online_Template__c,
                                                Required__c, Upload_Field__c, Community_Access__c,
                                                Filter_Field__c, Filter_Values__c, Review__c,  Keep_Filename__c
                                                FROM PSFileAttachDef__c
                                                WHERE (PSFileAttachTemplate__c = :templateDefId OR PSFileAttachTemplate__r.Template_Name__c = :templateDefId)
                                                 //ORDER BY Required__c DESC, Filename__c ASC])
                                                 ORDER BY Order__c ASC])
            {
                FileDef fd = new FileDef();
                fd.id = t.id;
                fd.defaultFilename = t.Filename__c;
                fd.filename = t.Filename__c;
                fd.allowedExtensions = parseExtensions(t.Allowed_Extensions__c);
                fd.description = t.Description__c;
                fd.onlineTemplateURL = t.Online_Template__c;
                fd.required = t.Required__c;
                fd.uploadField = t.Upload_Field__c;
                fd.communityAccess = t.Community_Access__c;
                fd.filterField = t.Filter_Field__c;
                fd.filterMatchValues = t.Filter_Values__c;
                fd.reviewOption = t.Review__c;
                fd.filenameImpl = t.Filename_Interface_Impl__c;
                fd.keepFilename = t.Keep_Filename__c;
               
                            // override name if interface class implementation (PSFileAttachTemplateFileNamingInterface)
                if (fd.filenameImpl != null)
                {
                   PSFileAttachTemplateFileNamingInterface instance = (PSFileAttachTemplateFileNamingInterface)Type.forName(fd.filenameImpl).newInstance();
                   fd.fileName = instance.getFilename(recordId, fd.defaultFilename);
                }
                System.debug('FileDef >' + JSON.serializePretty(fd));

                fileDefList.add(fd);
            }



            ////////////////////////////////////////////////////
            // filter out any that don't pass filter criteria //
            ////////////////////////////////////////////////////
            Set<String> filterFields = new Set<String>();
            for (FileDef fd : fileDefList)
            {
                if (fd.filterField != null && fd.filterField.length() > 0) filterFields.add(fd.filterField);
            }

            if (filterFields.size() > 0)
            {
                String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();

                String soqlStr = 'SELECT ' + convListToCSV(new List<String>(filterFields)) + ' FROM ' + sObjName + ' WHERE Id = \'' + recordId + '\'';
                System.debug('filter soqlStr = ' + soqlStr);

                List<Sobject> objList = Database.query(soqlStr);
                if (objList != null && objList.size() == 1)
                {
                    for (FileDef fd : fileDefList)
                    {
                        if (fd.filterField != null)
                        {
                            Object oval = getSobjectValue(objList[0], fd.filterField);
                            if (oval != null)
                            {
                                fd.filterValue = oval.toString();
                            }
                        }
                    }
                }

                List<FileDef> tmpDefList = new List<FileDef>();
                for (FileDef fd : fileDefList)
                {
                    if (fd.filterField != null && fd.filterMatchValues != null)
                    {
                        List<String> compareList = parseCSVString(fd.filterMatchValues);
                        if (compareList.contains(fd.filterValue))
                        {
                            tmpDefList.add(fd);
                        }
                    }
                    else {
                        tmpDefList.add(fd);
                    }
                }
                fileDefList = tmpDefList;

                //System.debug('fileDefList=' + JSON.serialize(fileDefList));
            }

            //////////////////////////////////
            // get content reviewed records //
            //////////////////////////////////
            //List<Id> contentReviewList = new List<Id>();
            Map<Id, PSFileAttachReview__c> revMap = new Map<Id, PSFileAttachReview__c>();
            for (PSFileAttachReview__c rev : [SELECT ContentDocumentId__c, LastModifiedBy.Name, LastModifiedDate FROM PSFileAttachReview__c WHERE LinkedEntityId__c = :recordId])
            {
                //contentReviewList.add(rev.ContentDocumentId__c);
                revMap.put(rev.ContentDocumentId__c, rev);
            }

            ///////////////////////////
            // get content documents //
            ///////////////////////////
            List<ContentDocumentLink> cdlList = [SELECT Id,  LinkedEntityId, ShareType, SystemModstamp, Visibility,
                                                        ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.FileExtension,
                                                        ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.Id
                                                        FROM ContentDocumentLink
                                                        WHERE linkedentityid = :recordId AND IsDeleted=false];

            for (FileDef fd : fileDefList)
            {
                for (ContentDocumentLink cdl : cdlList)
                {
                    if (fd.filename == cdl.ContentDocument.Title)
                    {
                        fd.uploaded = true;
                        fd.attachId = cdl.ContentDocument.Id;
                        fd.uploadDttm = cdl.ContentDocument.LastModifiedDate.format();
                        fd.uploadSize = cdl.ContentDocument.ContentSize;
                        fd.uploadType = cdl.ContentDocument.FileType;

                        if (revMap.containsKey(cdl.ContentDocument.Id))
                        {
                            PSFileAttachReview__c tmpRev = (PSFileAttachReview__c)revMap.get(cdl.ContentDocument.Id);
                            fd.reviewed = true;
                            fd.reviewerName = tmpRev.LastModifiedBy.Name;
                            fd.reviewerDate = tmpRev.LastModifiedDate.format();
                        }
                    }
                }
            }

            return fileDefList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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
        @AuraEnabled public String defaultFilename;
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
        @AuraEnabled public Integer maximum = null;
        @AuraEnabled public Boolean keepFilename = false;
        @AuraEnabled public String filenameImpl = null;

        @AuraEnabled public Boolean reviewed = false;
        @AuraEnabled public String reviewerName;
        @AuraEnabled public String reviewerDate;

        public String filterField;
        public String filterMatchValues;
        public String filterValue;

        @AuraEnabled public String attachId;
        @AuraEnabled public Boolean uploaded = false;
        @AuraEnabled public String uploadDttm;
        @AuraEnabled public Integer uploadSize;
        @AuraEnabled public String uploadType;
    }

}