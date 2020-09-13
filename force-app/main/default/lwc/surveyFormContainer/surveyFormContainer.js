
import { LightningElement, api, track } from 'lwc';
import getSurvey from '@salesforce/apex/SurveyFormController.getSurvey';
import getSurveyResponse from '@salesforce/apex/SurveyFormController.getSurveyResponse';
import submitSurvey from '@salesforce/apex/SurveyFormController.submitSurvey';

import surveyFormTemplate from './surveyFormContainer.html';
import surveySubmittedTemplate from './surveySubmitted.html';

export default class SurveyFormContainer extends LightningElement {
    @api recordId;
    @api invitationKey;
    @api formDisabled = false;
    @track alreadySubmitted = false;
    @track surveyName;
    @track questions = [];

    responseValueMap = new Map();

    render() {
        return this.alreadySubmitted
            ? surveySubmittedTemplate
            : surveyFormTemplate;
    }

    connectedCallback() {
        this.loadSurvey();
    }

    async loadSurvey() {
        await this.checkFormAvailability();
        if (!this.alreadySubmitted) {
            getSurvey({
                surveyId: this.recordId
            }).then(survey => {
                console.log(survey);
                this.surveyName = survey.name;
                this.questions = survey.questions;
            });
        }
    }

    async checkFormAvailability() {
        if (this.invitationKey) {
            await getSurveyResponse({
                invitationKey: this.invitationKey
            }).then(response => {
                console.log(response);
                this.recordId = response.surveyId;
                this.alreadySubmitted = response.responseSubmitted;
            })
        }
    }

    handleValueChange(event) {
        const response = event.detail;
        console.log('response: ', response);
        this.responseValueMap.set(response.questionId, response.value);
    }

    handleSubmit() {
        const responses = Object.fromEntries(this.responseValueMap);
        console.log(JSON.stringify(responses));
        submitSurvey({
            invitationKey: this.invitationKey,
            responses: JSON.stringify(responses)
        }).then(() => {
            this.alreadySubmitted = true;
        })
    }
}