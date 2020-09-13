@isTest
public class SurveyServiceTest {

    final static String SURVEY_NAME = 'SURVEY_NAME';
    final static String QUESTION_TEXT = 'QUESTION_TEXT';
    final static String QUESTION_TYPE = 'Choice';
    final static String CHOICE_OPTION_VALUE = 'CHOICE_OPTION_VALUE';

    @TestSetup  
    static void setupData() {
        Survey__c survey = new Survey__c(Name = SURVEY_NAME);
        insert survey;

        Survey_Question__c question = new Survey_Question__c(
            Survey__c = survey.Id,
            Question_Text__c = QUESTION_TEXT,
            Question_Type__c = QUESTION_TYPE
        );
        insert question;

        Survey_Question_Choice__c choice = new Survey_Question_Choice__c(
            Survey_Question__c = question.Id,
            Value__c = CHOICE_OPTION_VALUE
        );
        insert choice;
    }

    @isTest
    static void getSurvey_blankSurveyId_exceptionThrown() {
        final String surveyId = null;
        Exception serviceException;

        Test.startTest();
            try {
                SurveyService.getSurvey(surveyId);
            } catch (Exception e) {
                serviceException = e;
            }
        Test.stopTest();
        
        System.assertNotEquals(null, serviceException);
        System.assertEquals(
            String.format('Survey {0} not found', new List<String>{surveyId}), 
            serviceException.getMessage()
        );
    }

    @isTest
    static void getSurvey_correctSurveyId_wrapperReturned() {
        final String surveyId = [SELECT Id FROM Survey__c WHERE Name = :SURVEY_NAME LIMIT 1].Id;

        Exception serviceException;
        SurveyService.SurveyWrapper result;

        Test.startTest();
            try {
                result = SurveyService.getSurvey(surveyId);
            } catch (Exception e) {
                serviceException = e;
            }
        Test.stopTest();
        
        System.assertEquals(null, serviceException);
        System.assertNotEquals(null, result);

        System.assertEquals(surveyId, result.recordId);
        System.assertEquals(SURVEY_NAME, result.Name);

        System.assertEquals(false, result.questions.isEmpty());
        System.assertEquals(QUESTION_TEXT, result.questions[0].questionText);
        System.assertEquals(QUESTION_TYPE, result.questions[0].questionType);

        System.assertEquals(false, result.questions[0].choices.isEmpty());
        System.assertEquals(CHOICE_OPTION_VALUE, result.questions[0].choices[0].value);
    }

    @isTest
    static void getSurveyResponse_invalidInvitationKey_exceptionThrown() {
        final String invitationKey = null;

        Exception serviceException;
        SurveyService.SurveyResponseWrapper result;

        Test.startTest();
            try {
                result = SurveyService.getSurveyResponse(invitationKey);
            } catch (Exception e) {
                serviceException = e;
            }
        Test.stopTest();

        System.assertNotEquals(null, serviceException);
        System.assertEquals(null, result);
        System.assertEquals('Invitation Key invalid', serviceException.getMessage());
    }

    @isTest
    static void addNewQuestion_surveyIdProvided_questionAddedToSurvey() {
        final String surveyId = [SELECT Id FROM Survey__c WHERE Name = :SURVEY_NAME LIMIT 1].Id;

        Exception serviceException;
        SurveyService.QuestionWrapper result;

        Test.startTest();
            try {
                result = SurveyService.addNewQuestion(surveyId);
            } catch (Exception e) {
                serviceException = e;
            }
        Test.stopTest();

        System.assertEquals(null, serviceException);
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.recordId);
        
        Survey_Question__c questionRecord = [SELECT Id, Survey__c FROM Survey_Question__c WHERE Id = :result.recordId LIMIT 1];
        System.assertEquals(surveyId, questionRecord.Survey__c);
    }
}
