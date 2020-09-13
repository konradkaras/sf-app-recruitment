global class SurveyService {

    global static SurveyWrapper getSurvey(String surveyId) {
        Survey__c survey = [SELECT Id, Name FROM Survey__c WHERE Id = :surveyId LIMIT 1];
        if(survey != null) {
            SurveyWrapper surveyWrapper = new SurveyWrapper(survey);
            List<Survey_Question__c> questions = [SELECT Id, Question_Text__c, Question_Type__c,
                                                    (SELECT Id, Value__c FROM Survey_Question_Choices__r ORDER BY Name)
                                                    FROM Survey_Question__c
                                                    WHERE Survey__c = :surveyId
                                                    ORDER BY Name];
            surveyWrapper.wrapQuestions(questions);
            return surveyWrapper;
        } else {
            return null;
        }
    }

    global static SurveyResponseWrapper getSurveyResponse(String invitationKey) {
        Survey_Response__c response = [SELECT Survey__c, Response_Submitted__c 
                                        FROM Survey_Response__c 
                                        WHERE Invitation_Key__c = :invitationKey
                                        LIMIT 1];
        if(response != null) {
            return new SurveyResponseWrapper(response);
        } else {
            return null;
        }
    }

    global static QuestionWrapper addNewQuestion(String surveyId) {
        Survey_Question__c question = new Survey_Question__c();
        question.Survey__c = surveyId;
        question.Question_Text__c = '';
        question.Question_Type__c = 'Choice';
        insert question;

        Survey_Question_Choice__c choice = new Survey_Question_Choice__c();
        choice.Survey_Question__c = question.Id;
        choice.Value__c = '';
        insert choice;

        QuestionWrapper questionSchema = new QuestionWrapper(question);
        questionSchema.choices = new List<ChoiceWrapper> {new ChoiceWrapper(choice)};

        System.debug(JSON.serialize(questionSchema));
        return questionSchema;
    }

    global static void deleteQuestion(String questionId) {
        delete new Survey_Question__c(Id = questionId);
    }

    global static void updateQuestion(String questionId, String questionText, String questionType) {
        update new Survey_Question__c(
            Id = questionId,
            Question_Text__c = questionText,
            Question_Type__c = questionType
        );

        if(!questionType.equalsIgnoreCase('Choice')) {
            delete [SELECT Id FROM Survey_Question_Choice__c WHERE Survey_Question__c = :questionId];
        }
    }

    global static void updateQuestionChoice(String choiceId, String value) {
        update new Survey_Question_Choice__c(
            Id = choiceId,
            Value__c = value
        );
    }

    global static ChoiceWrapper addNewQuestionChoice(String questionId) {
        Survey_Question_Choice__c choice = new Survey_Question_Choice__c();
        choice.Survey_Question__c = questionId;
        choice.Value__c = '';
        insert choice;

        return new ChoiceWrapper(choice);
    }

    global static void deleteQuestionChoice(String choiceId) {
        delete new Survey_Question_Choice__c(Id = choiceId);
    }

    global static void submitSurveyAsFinal(String surveyId) {
        String finalVersionRecordType = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName()
                                            .get('Final_Version').getRecordTypeId();
        update new Survey__c(
            Id = surveyId,
            RecordTypeId = finalVersionRecordType
        );
    }

    global static void submitSurveyResponses(String invitationKey, Map<String,String> responsesMap) {
        if(String.isBlank(invitationKey)) { 
            return; 
        }

        Survey_Response__c surveyResponse = [SELECT Id 
                                        FROM Survey_Response__c 
                                        WHERE Invitation_Key__c = :invitationKey 
                                        LIMIT 1];
        if(surveyResponse != null) {
            surveyResponse.Response_Submitted__c = true;
            update surveyResponse;
            if(responsesMap != null && !responsesMap.isEmpty()) {
                List<Survey_Question_Response__c> questionResponses = new List<Survey_Question_Response__c>();
                for(String questionId : responsesMap.keySet()) {
                    questionResponses.add(new Survey_Question_Response__c(
                        Survey_Response__c = surveyResponse.Id,
                        Survey_Question__c = questionId,
                        Value__c = responsesMap.get(questionId)
                    ));
                }
                insert questionResponses;
            }
        }

    }

    global class SurveyWrapper {
        @AuraEnabled global String recordId;
        @AuraEnabled global String name;
        @AuraEnabled global List<QuestionWrapper> questions;

        global SurveyWrapper() {}

        global SurveyWrapper(Survey__c survey) {
            this.recordId = survey.Id;
            this.name = survey.Name;
        }

        global void wrapQuestions(List<Survey_Question__c> questionsList) {
            this.questions = new List<QuestionWrapper>();
            if(questionsList != null && !questionsList.isEmpty()) {
                for(Survey_Question__c q : questionsList) {
                    this.questions.add(new QuestionWrapper(q));
                }
            }
        }
    }

    global class QuestionWrapper {
        @AuraEnabled global String recordId;
        @AuraEnabled global String questionText;
        @AuraEnabled global String questionType;
        @AuraEnabled global List<ChoiceWrapper> choices;

        global QuestionWrapper() {}

        global QuestionWrapper(Survey_Question__c question) {
            this.recordId = question.Id;
            this.questionText = question.Question_Text__c;
            this.questionType = question.Question_Type__c;

            if(question.Survey_Question_Choices__r != null) {
                this.wrapQuestionChoices(question.Survey_Question_Choices__r);
            }
        }

        global void wrapQuestionChoices(List<Survey_Question_Choice__c> choicesList) {
            this.choices = new List<ChoiceWrapper>();
            if(choicesList != null && !choicesList.isEmpty()) {
                for(Survey_Question_Choice__c choice : choicesList) {
                    this.choices.add(new ChoiceWrapper(choice));
                }
            }
        }
    }

    global class ChoiceWrapper {
        @AuraEnabled global String recordId;
        @AuraEnabled global String value;

        global ChoiceWrapper() {}

        global ChoiceWrapper(Survey_Question_Choice__c choice) {
            this.recordId = choice.Id;
            this.value = choice.Value__c;
        }
    }

    global class SurveyResponseWrapper {
        @AuraEnabled global String surveyId;
        @AuraEnabled global Boolean responseSubmitted;

        global SurveyResponseWrapper() {}

        global SurveyResponseWrapper(Survey_Response__c response) {
            this.surveyId = response.Survey__c;
            this.responseSubmitted = response.Response_Submitted__c;
        }
    }
}
