trigger SurveyResponseTrigger on Survey_Response__c (before insert, after insert) {

    if(Trigger.isBefore && Trigger.isInsert) {
        final Integer hashLen = 10;
        for(Survey_Response__c responseRecord : Trigger.new) {
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            responseRecord.Invitation_Key__c = key.substring(0,hashLen);
        }
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Survey_Invitation' LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (Survey_Response__c responseRecord : Trigger.new) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(responseRecord.Contact__c);
            email.setTreatTargetObjectAsRecipient(true);
            email.setWhatId(responseRecord.Id);
            email.setTemplateId(emailTemplateId);
            email.setSaveAsActivity(false);
            emailsToSend.add(email);
        }
        Messaging.sendEmail(emailsToSend);
    }
}