public class PSFileAttachCardController {
  @AuraEnabled
  public static void setFile(String recordId, String fileId, String fileName, String bField)
  {
      System.debug('setFile...');
      System.debug('recordId=' + recordId);
      System.debug('fileId=' + fileId);
      System.debug('fileName=' + fileName);
      System.debug('bField=' + bField);

      try {
         List<ContentVersion> fileList = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :fileId];
         if (fileList != null && fileList.size() == 1)
         {
             fileList[0].Title = fileName;
         }
         update fileList;

         if (bField != null)
         {
             Id tmpRecId = recordId;
             SObject obj = tmpRecId.getSObjectType().newSObject(tmpRecId);
             obj.put(bField, true);
             update obj;

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