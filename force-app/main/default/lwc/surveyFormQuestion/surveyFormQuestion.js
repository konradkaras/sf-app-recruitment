import { LightningElement, api } from 'lwc';

export default class SurveyFormQuestion extends LightningElement {
    recordId;
    questionText;
    questionType;
    choices = [];

    responseValue;

    @api disabled = false;
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

    get isNumber() {
        return this.questionType === 'Number';
    }

    get options() {
        return this.choices.map(choice => {
            return { label: choice.value, value: choice.value };
        });
    }

    handleResponseInput(event) {
        const value = event.detail.value
        const inputEvent = new CustomEvent("valuechange", {
            detail: { questionId: this.recordId, value }
        });
        this.dispatchEvent(inputEvent);
    }
}