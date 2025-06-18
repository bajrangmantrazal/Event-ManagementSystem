public with sharing class UserAccessController {
    @AuraEnabled(cacheable=true)
    public static String getUserRoleOrProfile() {
        User u = [SELECT Id, UserRole.Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        if (u.UserRole != null) return u.UserRole.Name;
        return u.Profile.Name;
    }
}