global without sharing class SurveyEditorController {

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
    global static SurveyService.QuestionWrapper addNewQuestion(String surveyId) {
        try{
            SurveyService.QuestionWrapper response = SurveyService.addNewQuestion(surveyId);
            return response;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    global static void deleteQuestion(String questionId) {
        try{
            SurveyService.deleteQuestion(questionId);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    global static void updateQuestion(String questionId, String questionText, String questionType) {
        try{
            SurveyService.updateQuestion(questionId, questionText, questionType);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    global static void updateQuestionChoice(String choiceId, String value) {
        try{
            SurveyService.updateQuestionChoice(choiceId, value);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    global static void deleteQuestionChoice(String choiceId) {
        try{
            SurveyService.deleteQuestionChoice(choiceId);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    global static SurveyService.ChoiceWrapper addNewQuestionChoice(String questionId) {
        try{
            SurveyService.ChoiceWrapper response = SurveyService.addNewQuestionChoice(questionId);
            return response;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    global static void submitSurveyAsFinal(String surveyId){
        try{
            SurveyService.submitSurveyAsFinal(surveyId);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

}
