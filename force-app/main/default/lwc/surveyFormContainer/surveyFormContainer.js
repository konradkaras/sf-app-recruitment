
import { LightningElement, api, track } from 'lwc';
import getSurvey from '@salesforce/apex/SurveyFormController.getSurvey';
import getSurveyResponse from '@salesforce/apex/SurveyFormController.getSurveyResponse';
import submitSurvey from '@salesforce/apex/SurveyFormController.submitSurvey';

import surveyFormTemplate from './surveyFormContainer.html';
import surveyNotFoundTemplate from './surveyNotFound.html';
import surveySubmittedTemplate from './surveySubmitted.html';

export default class SurveyFormContainer extends LightningElement {
    @api recordId;
    @api invitationKey;
    @api formDisabled = false;

    @track surveyNotFound = false;
    @track alreadySubmitted = false;
    @track surveyName;
    @track questions = [];

    formLoaded = false;
    responseValueMap = new Map();

    get formReady() {
        return this.formLoaded && !this.formDisabled;
    }

    render() {
        return this.surveyNotFound
            ? surveyNotFoundTemplate
            : this.alreadySubmitted
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
                this.surveyName = survey.name;
                this.questions = survey.questions;
                this.formLoaded = true;
            }).catch(exception => {
                console.error(exception);
                this.surveyNotFound = true;
            });
        }
    }

    async checkFormAvailability() {
        if (this.invitationKey) {
            await getSurveyResponse({
                invitationKey: this.invitationKey
            }).then(response => {
                this.recordId = response.surveyId;
                this.alreadySubmitted = response.responseSubmitted;
            }).catch(exception => {
                console.error(exception);
                this.surveyNotFound = true;
            });
        }
    }

    handleValueChange(event) {
        const response = event.detail;
        this.responseValueMap.set(response.questionId, response.value);
    }

    handleSubmit() {
        const responses = Object.fromEntries(this.responseValueMap);
        submitSurvey({
            invitationKey: this.invitationKey,
            responses: JSON.stringify(responses)
        }).then(() => {
            this.alreadySubmitted = true;
        }).catch(exception => {
            console.error(exception);
        });
    }
}