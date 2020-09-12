public with sharing class SurveyEditorController {

    @AuraEnabled
    public static SurveyService.SurveyWrapper getSurvey(String surveyId){
        try{
            SurveyService.SurveyWrapper response = SurveyService.getSurvey(surveyId);
            return response;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static SurveyService.QuestionWrapper addNewQuestion(String surveyId) {
        try{
            SurveyService.QuestionWrapper response = SurveyService.addNewQuestion(surveyId);
            return response;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static void deleteQuestion(String questionId) {
        try{
            SurveyService.deleteQuestion(questionId);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static void updateQuestion(String questionId, String questionText, String questionType) {
        try{
            SurveyService.updateQuestion(questionId, questionText, questionType);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static void updateQuestionChoice(String choiceId, String value) {
        try{
            SurveyService.updateQuestionChoice(choiceId, value);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static void deleteQuestionChoice(String choiceId) {
        try{
            SurveyService.deleteQuestionChoice(choiceId);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static SurveyService.ChoiceWrapper addNewQuestionChoice(String questionId) {
        try{
            SurveyService.ChoiceWrapper response = SurveyService.addNewQuestionChoice(questionId);
            return response;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

}
