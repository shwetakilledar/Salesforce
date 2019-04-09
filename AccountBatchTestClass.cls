@isTest
private class AccountBatchTestClass {

    static testmethod void test() {
    
    // Create test accounts to be updated
    // by the batch job.

        List<Lead> leadList = new List<Lead>();
        
        for (Integer i=0;i<200;i++) {
            Lead l = new Lead(LastName = 'Test LastName ' + i,Company= 'TestCompany '+i,Product__c='CHP',Status='Open', Campaign__c='Healthcare');
            leadList.add(l);
        }
        
       	insert leadList;
        
        Test.startTest();
        
        AccountBatchClass c = new AccountBatchClass();
       
        Database.executeBatch(c);
        
        Test.stopTest();
        
        // Verify accounts updated
        Account[] accUpdatedList = [SELECT Id,Name FROM Account];
        System.assert(accUpdatedList[0].Name.Contains('TestCompany'));
        }
}