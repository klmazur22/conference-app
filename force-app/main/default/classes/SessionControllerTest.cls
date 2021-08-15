@IsTest private class SessionControllerTest {
    
    @TestSetup private static void setup(){
        
        List<Schema.PicklistEntry> ple = Session__c.Room__c.getDescribe().getPicklistValues();
        Session__c session1 = new Session__c(Name = 'Session1', Room__c = ple[0].getLabel(), Date_and_Time__c = DateTime.now(), Description__c = 'Session1 for SessionControllerTest');
        Session__c session2 = new Session__c(Name = 'Session2', Room__c = ple[1].getLabel(), Date_and_Time__c = DateTime.now(), Description__c = 'Session2 for SessionControllerTest');
        
        List<Session__c> sessions = new List<Session__c>{session1, session2};
        insert sessions;
        Contact contact1 = new Contact(FirstName = 'Contact1', LastName = 'Contact1', Email = 'contact1@example.com', Phone = '+123456789');
        Contact contact2 = new Contact(FirstName = 'Contact2', LastName = 'Contact1', Email = 'contact2@example.com', Phone = '+987654321');
        List<Contact> contacts = new List<Contact>{contact1, contact2};
        insert contacts;
        List<Session_Speaker__c> speakerList = new List<Session_Speaker__c>();
        speakerList.add(new Session_Speaker__c(Speaker__c = contact1.Id, Session__c = session1.Id));
        speakerList.add(new Session_Speaker__c(Speaker__c = contact2.Id, Session__c = session2.Id));
        insert speakerList;
    }

    @IsTest
    static void testGetSessionsWithoutKey() {
        Test.startTest();
        System.assertEquals(2, SessionController.getSessions('').size());
        Test.stopTest();
    }

    @IsTest
    static void testGetSessionsWithCorrectKey() {
        Test.startTest();
        System.assertEquals(1, SessionController.getSessions('Session1').size());
        Test.stopTest();
    }

    @IsTest
    static void testGetSessionsWithIncorrectKey() {
        Test.startTest();
        System.assertEquals(0, SessionController.getSessions('abcdef').size());
        Test.stopTest();
    }

    @IsTest
    static void testGetSessionWithValidId() {
        Session__c session1 = [SELECT Id FROM Session__c WHERE Name = 'Session1'];
        
        Test.startTest();
        System.assertEquals('Session1', SessionController.getSession(session1.Id).Name);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetSessionWithInvalidId() {
        Test.startTest();
        try{
            Session__c session = SessionController.getSession('a11110000011111111');
        }
        catch(Exception e){
            System.debug(e.getMessage());
        	System.assertEquals(true, e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testAddSession() {
        List<Contact> speakerList = [SELECT Id FROM Contact LIMIT 2];
        List<Id> speakerIdList = new List<Id>();
        for(Contact speaker: speakerList)
            speakerIdList.add(speaker.Id);
        List<Schema.PicklistEntry> ple = Session__c.Room__c.getDescribe().getPicklistValues();
        
        Test.startTest();
        Id newSessionId = SessionController.addSession('Session3', ple[2].getLabel(), 'Session3 for SessionControllerTest', DateTime.now(), speakerIdList);
        System.assertNotEquals(null, newSessionId);
        List<Session__c> allSessions = [SELECT Id FROM Session__c];
        System.assertEquals(3, allSessions.size());
        System.assertEquals(true, [SELECT Id FROM Session_Speaker__c WHERE Session__c =:newSessionId].size() > 0);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetLocationPickListValuesIntoList() {
        Test.startTest();
        System.assertEquals(true, SessionController.getLocationPickListValuesIntoList().size() > 0);
        Test.stopTest();
    }
    
    @IsTest
    static void testSearchContactWithoutKey() {
        Test.startTest();
        System.assertEquals(null, SessionController.searchContact(''));
        Test.stopTest();
    }
    
    @IsTest
    static void testSearchContactByName() {
        Test.startTest();
        System.assertEquals(2, SessionController.searchContact('Contact').size());
        Test.stopTest();
    }
    
    @IsTest
    static void testSearchContactByEmail() {
        Test.startTest();
        System.assertEquals(2, SessionController.searchContact('@example.com').size());
        Test.stopTest();
    }
    
    @IsTest
    static void testSearchContactByPhone() {
        Test.startTest();
        System.assertEquals(1, SessionController.searchContact('+123').size());
        Test.stopTest();
    }
}