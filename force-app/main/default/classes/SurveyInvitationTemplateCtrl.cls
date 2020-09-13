public class SurveyInvitationTemplateCtrl {
    public String invitationHash {get;set;}
    public String getInvitationLink() {
        Site surveySite = [SELECT Id FROM Site WHERE Name = 'SurveyForm'];
        SiteDetail mySiteDetail = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :surveySite.Id];
        return mySiteDetail.SecureURL + '?survey=' + invitationHash;
    }
}
