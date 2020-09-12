import { LightningElement, api } from 'lwc';
import addNewQuestionChoice from '@salesforce/apex/SurveyEditorController.addNewQuestionChoice';
import deleteQuestionChoice from '@salesforce/apex/SurveyEditorController.deleteQuestionChoice';
import updateQuestion from '@salesforce/apex/SurveyEditorController.updateQuestion';

const INPUT_TIMEOUT = 500;

export default class SurveyEditorQuestion extends LightningElement {

    recordId;
    questionText;
    questionType;
    choices = [];

    inputTimeout;

    @api
    get questionRecord() {
        return {
            recordId: this.recordId,
            questionText: this.questionText,
            questionType: this.questionType,
            choices: this.choices
        }
    }
    set questionRecord(value) {
        this.recordId = value.recordId;
        this.questionText = value.questionText;
        this.questionType = value.questionType;
        this.choices = value.choices ? value.choices : [];
    }

    get choicesAllowed() {
        return this.questionType === 'Choice';
    }

    get questionTypes() {
        return [
            { label: 'Text', value: 'Text' },
            { label: 'Number', value: 'Number' },
            { label: 'Option Choice', value: 'Choice' },
        ];
    }

    handleTypeChange(event) {
        const rollbackType = this.questionType;
        const rollbackChoices = [...this.choices];

        this.questionType = event.detail.value
        if (this.questionType !== 'Choice') {
            this.choices = [];
        }

        updateQuestion({
            questionId: this.recordId,
            questionText: this.questionText,
            questionType: this.questionType
        }).catch(exception => {
            console.error(exception);
            this.questionType = rollbackType;
            this.choices = rollbackChoices;
        });
    }

    handleAddNewChoice() {
        addNewQuestionChoice({
            questionId: this.recordId
        }).then(result => {
            this.choices = [...this.choices, result];
        });
    }

    handleDeleteQuestion() {
        const deleteEvent = new CustomEvent("deletequestion", {
            detail: this.recordId
        });
        this.dispatchEvent(deleteEvent);
    }

    handleDeleteChoice(event) {
        const choiceId = event.detail;
        const rollback = [...this.choices];
        this.choices = this.choices.filter(item => (
            item.recordId !== choiceId
        ));
        deleteQuestionChoice({
            choiceId
        }).catch(exception => {
            console.error(exception);
            this.choices = rollback;
        });
    }

    handleInputChange(event) {
        const rollbackText = this.questionText;

        this.questionText = event.target.value;

        clearTimeout(this.inputTimeout);
        this.inputTimeout = setTimeout(async () => {
            updateQuestion({
                questionId: this.recordId,
                questionText: this.questionText,
                questionType: this.questionType
            }).catch(exception => {
                console.error(exception);
                this.questionText = rollbackText;
            })
        }, INPUT_TIMEOUT)
    }
}