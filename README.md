# Salesforce Recruitment App

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

This app allows you to create configurable Surveys and send them to your Contacts.

### Prerequisites

The app uses Salesforce Force.com Public Site to expose the survey externally.

`config/project-scratch-def.json` contains following features:
```json
"features": [
    "Sites"
  ]
```

When pushed, the SFDX will create a default Site for the app needs.

If you want to define the Site on your own, remove the `"Sites"` option from features.


### SFDX Scratch Org Deployment

To push the code to your scratch org:

`sfdx force:source:push`

The app has a Permission Set defined `Recruitment_App_Admin`

To assign the Permission Set to your user:

`sfdx force:user:permset:assign --permsetname Recruitment_App_Admin`