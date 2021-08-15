public with sharing class SessionController {
    @AuraEnabled(cacheable=true)
    public static List<Session__c> getSessions(String searchKey) {
        if (String.isBlank(searchKey)) {
            return [SELECT Id, Name, toLabel(Room__c), Description__c, format(Date_and_Time__c) dateTime,
                    (SELECT Speaker__r.Id, Speaker__r.Name, Speaker__r.Description, Speaker__r.Email, Speaker__r.Picture_URL__c FROM Session_Speakers__r)
                    FROM Session__c ORDER BY Date_and_Time__c LIMIT 100];
        } else {
            String key = '%' + searchKey + '%';
            return [SELECT Id, Name, toLabel(Room__c), Description__c, format(Date_and_Time__c) dateTime,
                    (SELECT Speaker__r.Id, Speaker__r.Name, Speaker__r.Description, Speaker__r.Email, Speaker__r.Picture_URL__c FROM Session_Speakers__r)
                    FROM Session__c WHERE Name LIKE :key ORDER BY Date_and_Time__c LIMIT 100];
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Session__c getSession(Id sessionId) {
        List<Session__c> sessions = [SELECT Id, Name, toLabel(Room__c), Description__c, format(Date_and_Time__c) dateTime,
                                     (SELECT Speaker__r.Id, Speaker__r.Name, Speaker__r.Description, Speaker__r.Email, Speaker__r.Picture_URL__c FROM Session_Speakers__r)
                                     FROM Session__c WHERE Id = :sessionId];
        if (sessions.size() < 1) {
            throw new AuraHandledException('Could not find session');
        }
        return sessions[0];
    }
    
    @AuraEnabled
    public static Id addSession(String sessionName, String sessionLocation, String sessionDescription, DateTime sessionTime, List<Id> sessionSpeakerId) {
        try{
            Session__c newSession = new Session__c(Name = sessionName, Room__c = sessionLocation, Description__c = sessionDescription, Date_and_Time__c = sessionTime);
            insert newSession;
            List<Session_Speaker__c> speakerList = new List<Session_Speaker__c>();
            Set<Id> sessionSpeakerIdSet = new Set<Id>(sessionSpeakerId);
            for(Id speakerId: sessionSpeakerIdSet){
                speakerList.add(new Session_Speaker__c(Speaker__c = speakerId, Session__c = newSession.Id));
            }
            insert speakerList;
            return newSession.Id;
        }
        catch(Exception e){ throw new AuraHandledException('Session was not created: ' + e.getMessage()); }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getLocationPickListValuesIntoList(){
        try{
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Session__c.Room__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;
        }
        catch(Exception e){ throw new AuraHandledException('Locations not found'); }
    }
    
    @AuraEnabled
    public static List<Contact> searchContact(String searchTerm) {
        if (searchTerm.length() < 1) {
            return null;
        } else {
            String key = '%' + searchTerm + '%';
            return [SELECT Id, Name, Email, Phone
                    FROM Contact WHERE Name LIKE :key OR Email LIKE :key OR Phone LIKE :key ORDER BY Name LIMIT 10];
        }
    }
}