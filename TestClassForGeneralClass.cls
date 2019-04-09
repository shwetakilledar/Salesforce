@isTest
public class TestClassForGeneralClass {
    
    static testmethod void test() {
    
        List<Lead> leadList = new List<Lead>();
        List<Account> ac = new List<Account>();
        

       	 for (Integer i=0;i<200;i++) {
            Lead l = new Lead(
                		LastName = 'TBD',
                 		Company= 'TestCompany '+i,
                		Product__c='CHP',
                		Status='Open', 
                		Campaign__c='Healthcare',
                		OwnerId='005j000000BCElWAAX'
            );
            leadList.add(l);
        }
        
        try{
            insert leadList;
        }catch(Exception e){
            System.debug(e);
        }
        
        
         for (Integer i=0;i<200;i++) {
            Account a = new Account(Name='TestCompany '+i,OwnerId='005j000000BCElWAAX');
            ac.add(a);
        }
        
        try{
            insert ac;
        }catch(Exception e){
            System.debug(e);
        }
        
         Test.startTest();
        GeneralTestClass obj = new GeneralTestClass();
        obj.mainMethod();
         Test.stopTest();
     	
        Lead[] accUpdatedList = [SELECT Id, LastName FROM Lead];
        System.assert(accUpdatedList[0].LastName.Contains('TBD_'));
        System.debug('here'+accUpdatedList[0].LastName);
        
    }
}