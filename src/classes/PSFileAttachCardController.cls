public without sharing class PSFileAttachCardController {
  @AuraEnabled
  public static void setFileApex(String recordId, String fileId, String fileName, String bField, Boolean commAccess, Boolean keepFilename, String fileNameImpl)
  {
      System.debug('setFileApex...');
      System.debug('recordId=' + recordId);
      System.debug('fileId=' + fileId);
      System.debug('fileName=' + fileName);
      System.debug('fileNameImpl=' + fileNameImpl);
      System.debug('keepFilename=' + keepFilename);
      System.debug('bField=' + bField);

      try {
        // override name if interface class implementation (PSFileAttachTemplateFileNamingInterface)
        if (keepFilename) 
        {
            fileName = null;
        } 

         // update filename on content document
         List<ContentVersion> fileList = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :fileId];
         if (fileList != null && fileList.size() == 1)
         {
             if (fileName != null) fileList[0].Title = fileName;
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
  public static String setReviewApex(String recordId, String fileId, Boolean reviewedFlag)
  {
      System.debug('setReviewApex...');
      System.debug('recordId=' + recordId);
      System.debug('fileId=' + fileId);
      System.debug('reviewedFlag=' + reviewedFlag);

      Map<String,String> respMap = new Map<String, String>();
      respMap.put('reviewerName', null);
      respMap.put('reviewerDate', null);

      try {
          
         Map<Id, PSFileAttachReview__c> revMap = new Map<Id, PSFileAttachReview__c>();
         for (PSFileAttachReview__c rev : [SELECT Id, ContentDocumentId__c, LastModifiedBy.Name, LastModifiedDate FROM PSFileAttachReview__c WHERE LinkedEntityId__c = :recordId AND ContentDocumentId__c = :fileId])
         {
            revMap.put(rev.ContentDocumentId__c, rev);
            if (reviewedFlag == false)
            {
               delete rev;
            }
         }
         
         if (!revMap.containsKey(fileId) && reviewedFlag == true)
         {
            PSFileAttachReview__c rev = new PSFileAttachReview__c();
            rev.LinkedEntityId__c = recordId;
            rev.ContentDocumentId__c = fileId;
            insert rev;

            rev = [SELECT LastModifiedBy.Name, LastModifiedDate FROM PSFileAttachReview__c WHERE Id = :rev.Id];
            respMap.put('reviewerName', rev.LastModifiedBy.Name);
            respMap.put('reviewerDate', rev.LastModifiedDate.format());
         }

         return JSON.serialize(respMap);

      } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
      }
  }

  @AuraEnabled
  public static void deleteFileApex(String recordId, String fileId, String bField)
  {
      System.debug('deleteFileApex...');
      System.debug('recordId=' + recordId);
      System.debug('fileId=' + fileId);
      System.debug('bField=' + bField);

      try {
        ContentDocument cd = new ContentDocument();
        cd.Id = fileId;
        delete cd;

         ////////////////////////
         // clear upload field //
         ////////////////////////
         if (bField != null)
         {
             Id tmpRecId = recordId;
             SObject obj = tmpRecId.getSObjectType().newSObject(tmpRecId);
             obj.put(bField, false);
             update obj;             
         }

         //////////////////////////////////////////
         // delete existing review doc if exists //
         //////////////////////////////////////////
         List<PSFileAttachReview__c> revList= [SELECT Id 
                                             FROM PSFileAttachReview__c 
                                            WHERE LinkedEntityId__c = :recordId AND ContentDocumentId__c = :fileId];
         if (revList != null && revList.size() > 0) delete revList;

      } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
      }
  }
}