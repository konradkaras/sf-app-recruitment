import { LightningElement, api } from 'lwc';
import updateQuestionChoice from '@salesforce/apex/SurveyEditorController.updateQuestionChoice';

const INPUT_TIMEOUT = 500;

export default class SurveyEditorQuestionChoice extends LightningElement {

    recordId;
    value;

    @api
    get choiceRecord() {
        return {
            recordId: this.recordId,
            value: this.value
        }
    }
    set choiceRecord(value) {
        this.recordId = value.recordId;
        this.value = value.value;
    }

    handleDeleteChoice() {
        const deleteEvent = new CustomEvent("deletechoice", {
            detail: this.recordId
        });
        this.dispatchEvent(deleteEvent);
    }

    handleInputChange(event) {
        const rollbackValue = this.value;

        this.value = event.target.value;

        clearTimeout(this.inputTimeout);
        this.inputTimeout = setTimeout(async () => {
            updateQuestionChoice({
                choiceId: this.recordId,
                value: this.value,
            }).catch(exception => {
                console.error(exception);
                this.value = rollbackValue;
            });
        }, INPUT_TIMEOUT)
    }
}