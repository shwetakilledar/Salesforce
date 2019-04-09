@isTest
private class ContactBatchTestClass {

    static testmethod void test() {
    
    // Create test accounts to be updated
    // by the batch job.

        List<Lead> leadList = new List<Lead>();
        List<Account> ac = new List<Account>();
        
        for (Integer i=0;i<200;i++) {
            Lead l = new Lead(LastName = 'TestLastName ' + i,Company= 'TestCompany '+i,Product__c='CHP',Status='Open', Campaign__c='Healthcare',OwnerId='005j000000BCElWAAX');
            leadList.add(l);
        }
        
        try{
        	insert leadList;    
        }catch(Exception e){
            System.debug('List Exception'+e);
        }
       	
       	
        System.debug('here after creating leads'+leadList);
        List<Lead> newLi = [Select LastName, Company, OwnerId from Lead];
        List<Account> accnts = [Select Name from Account];
        
        System.debug('Check new leads and acconts');
        
        for(Lead l: newLi){
             boolean flag = false;
            for(Account acc: accnts){
                if(acc.Name.trim().equals(l.Company.trim())){
                    flag = true;
                    break;
               }
            }
            if(!flag) {
               Account a = new Account(Name=l.Company,OwnerId = l.OwnerId);
           	   ac.add(a);
            }
            
        }
        
        System.debug('Okay lets check');
        try{
        	 insert ac;
        }catch(Exception e){
            System.debug('Account Exception'+e);
        }
       	
       
        List<Account> newAc = [Select Name from Account];
        System.debug('Added accounts');
        
        Test.startTest();
        SYstem.debug('In test'+newAc[0]);
        
        //Call Contact
        ContactBatchClass c = new ContactBatchClass();
       	Database.executeBatch(c);
        Test.stopTest();
        
        // Verify accounts updated
        Account[] accUpdatedList = [SELECT Id, Name FROM Account];
        System.assert(accUpdatedList[0].Name.Contains('TestCompany'));
        
    	Contact[] newContacts = [Select Id, LastName, AccountId from Contact];
    	
    
    	System.assert(newContacts[0].LastName.Contains('TestLastName'));
	}
}