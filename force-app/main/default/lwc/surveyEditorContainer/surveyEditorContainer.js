import { LightningElement, api, track } from 'lwc';
import getSurvey from '@salesforce/apex/SurveyEditorController.getSurvey';
import addNewQuestion from '@salesforce/apex/SurveyEditorController.addNewQuestion';
import deleteQuestion from '@salesforce/apex/SurveyEditorController.deleteQuestion';
import submitSurveyAsFinal from '@salesforce/apex/SurveyEditorController.submitSurveyAsFinal';

export default class SurveyEditorContainer extends LightningElement {
    @api recordId;
    @track questions = [];

    connectedCallback() {
        this.loadSurvey();
    }

    loadSurvey() {
        getSurvey({
            surveyId: this.recordId
        }).then(survey => {
            this.questions = survey.questions;
        });
    }

    handleAddNewQuestion() {
        addNewQuestion({
            surveyId: this.recordId
        }).then(result => {
            this.questions = [...this.questions, result];
        });
    }

    handleDeleteQuestion(event) {
        const questionId = event.detail;
        const rollback = [...this.questions];
        this.questions = this.questions.filter(item => (
            item.recordId !== questionId
        ));
        deleteQuestion({
            questionId
        }).catch(exception => {
            console.error(exception);
            this.questions = rollback;
        });
    }

    handleSubmitAsFinal() {
        submitSurveyAsFinal({
            surveyId: this.recordId
        }).then(() => {
            window.location.reload();
        }).catch(exception => {
            console.error(exception);
        });
    }
}