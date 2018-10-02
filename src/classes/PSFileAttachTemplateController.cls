public class PSFileAttachTemplateController {
      
  @AuraEnabled
  public static List<FileDef> getFileDefs(String templateDefId, String recordId)
  {
      System.debug('getTemplateDef...');

      try {
        List<FileDef> fileDefList = new List<FileDef>();
        for (PSFileAttachDef__c t : [SELECT Id, Filename__c, Allowed_Extensions__c, Help_Text__c, Online_Template__c, 
                                            Required__c, Upload_Field__c
                                       FROM PSFileAttachDef__c 
                                      WHERE PSFileAttachTemplate__c = :templateDefId 
                                      ORDER BY Required__c DESC, Filename__c ASC])
        {
            FileDef fd = new FileDef();
            fd.id = t.id;
            fd.filename = t.Filename__c;
            fd.allowedExtensions = parseExtensions(t.Allowed_Extensions__c);
            fd.helpText = t.Help_Text__c;
            fd.onlineTemplateURL = t.Online_Template__c;
            fd.required = t.Required__c;
            fd.uploadField = t.Upload_Field__c;
            fileDefList.add(fd);
        }

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
                }
            }
        }                                      

         return fileDefList;
      } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
      }
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

    public class FileDef
    {
        @AuraEnabled public String id;
        @AuraEnabled public String filename;
        @AuraEnabled public String allowedExtensions;
        @AuraEnabled public String helpText;
        @AuraEnabled public String onlineTemplateURL;
        @AuraEnabled public Boolean required = false;
        @AuraEnabled public String uploadField;

        @AuraEnabled public String attachId;
        @AuraEnabled public Boolean uploaded = false;
        @AuraEnabled public String uploadDttm;
        @AuraEnabled public Integer uploadSize;
        @AuraEnabled public String uploadType;
    }

}