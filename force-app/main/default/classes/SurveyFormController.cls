global without sharing class SurveyFormController {

    @AuraEnabled
    global static SurveyService.SurveyWrapper getSurvey(String surveyId){
        try{
            SurveyService.SurveyWrapper response = SurveyService.getSurvey(surveyId);
            return response;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    global static SurveyService.SurveyResponseWrapper getSurveyResponse(String invitationKey){
        try{
            return SurveyService.getSurveyResponse(invitationKey);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    global static void submitSurvey(String invitationKey, String responses){
        try{
            Map<String,String> responsesMap = (Map<String,String>) JSON.deserialize(responses, Map<String,String>.class);
            SurveyService.submitSurveyResponses(invitationKey, responsesMap);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}
