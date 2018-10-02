public without sharing class PSFileAttachCardController {
  @AuraEnabled
  public static void setFile(String recordId, String fileId, String fileName, String bField, Boolean commAccess)
  {
      System.debug('setFile...');
      System.debug('recordId=' + recordId);
      System.debug('fileId=' + fileId);
      System.debug('fileName=' + fileName);
      System.debug('bField=' + bField);

      try {
        // update filename on content document
         List<ContentVersion> fileList = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :fileId];
         if (fileList != null && fileList.size() == 1)
         {
             fileList[0].Title = fileName;
         }
         update fileList;

         // update the boolean field on object
         if (bField != null)
         {
             Id tmpRecId = recordId;
             SObject obj = tmpRecId.getSObjectType().newSObject(tmpRecId);
             obj.put(bField, true);
             update obj;

         }

         // update document for community access
         if (commAccess)
         {
             List<ContentDocumentLink> cdlList = [SELECT Id, ShareType, Visibility 
                                                    FROM ContentDocumentLink 
                                                   WHERE ContentDocumentId = :fileId 
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

      } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
      }
  }

  @AuraEnabled
  public static void deleteFile(String recordId, String fileId, String bField)
  {
      System.debug('deleteFile...');
      System.debug('recordId=' + recordId);
      System.debug('fileId=' + fileId);
      System.debug('bField=' + bField);

      try {
        ContentDocument cd = new ContentDocument();
        cd.Id = fileId;
        delete cd;

         if (bField != null)
         {
             Id tmpRecId = recordId;
             SObject obj = tmpRecId.getSObjectType().newSObject(tmpRecId);
             obj.put(bField, false);
             update obj;             
         }

      } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
      }
  }
}