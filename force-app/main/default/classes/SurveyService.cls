public class SurveyService {

    public static SurveyWrapper getSurvey(String surveyId) {
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

    public static QuestionWrapper addNewQuestion(String surveyId) {
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

    public static void deleteQuestion(String questionId) {
        delete new Survey_Question__c(Id = questionId);
    }

    public static void updateQuestion(String questionId, String questionText, String questionType) {
        update new Survey_Question__c(
            Id = questionId,
            Question_Text__c = questionText,
            Question_Type__c = questionType
        );

        if(!questionType.equalsIgnoreCase('Choice')) {
            delete [SELECT Id FROM Survey_Question_Choice__c WHERE Survey_Question__c = :questionId];
        }
    }

    public static void updateQuestionChoice(String choiceId, String value) {
        update new Survey_Question_Choice__c(
            Id = choiceId,
            Value__c = value
        );
    }

    public static ChoiceWrapper addNewQuestionChoice(String questionId) {
        Survey_Question_Choice__c choice = new Survey_Question_Choice__c();
        choice.Survey_Question__c = questionId;
        choice.Value__c = '';
        insert choice;

        return new ChoiceWrapper(choice);
    }

    public static void deleteQuestionChoice(String choiceId) {
        delete new Survey_Question_Choice__c(Id = choiceId);
    }

    public class SurveyWrapper {
        @AuraEnabled public String recordId;
        @AuraEnabled public String name;
        @AuraEnabled public List<QuestionWrapper> questions;

        public SurveyWrapper() {}

        public SurveyWrapper(Survey__c survey) {
            this.recordId = survey.Id;
            this.name = survey.Name;
        }

        public void wrapQuestions(List<Survey_Question__c> questionsList) {
            this.questions = new List<QuestionWrapper>();
            if(questionsList != null && !questionsList.isEmpty()) {
                for(Survey_Question__c q : questionsList) {
                    this.questions.add(new QuestionWrapper(q));
                }
            }
        }
    }

    public class QuestionWrapper {
        @AuraEnabled public String recordId;
        @AuraEnabled public String questionText;
        @AuraEnabled public String questionType;
        @AuraEnabled public List<ChoiceWrapper> choices;

        public QuestionWrapper() {}

        public QuestionWrapper(Survey_Question__c question) {
            this.recordId = question.Id;
            this.questionText = question.Question_Text__c;
            this.questionType = question.Question_Type__c;

            if(question.Survey_Question_Choices__r != null) {
                this.wrapQuestionChoices(question.Survey_Question_Choices__r);
            }
        }

        public void wrapQuestionChoices(List<Survey_Question_Choice__c> choicesList) {
            this.choices = new List<ChoiceWrapper>();
            if(choicesList != null && !choicesList.isEmpty()) {
                for(Survey_Question_Choice__c choice : choicesList) {
                    this.choices.add(new ChoiceWrapper(choice));
                }
            }
        }
    }

    public class ChoiceWrapper {
        @AuraEnabled public String recordId;
        @AuraEnabled public String value;

        public ChoiceWrapper() {}

        public ChoiceWrapper(Survey_Question_Choice__c choice) {
            this.recordId = choice.Id;
            this.value = choice.Value__c;
        }
    }
}
