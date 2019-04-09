global class AccountBatchClass implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Company, OwnerId, Name, FirstName, LastName, Email,'+
            'Phone, Title, Status, Reason_for_state_change__c , State_Change_Description__c, '+
            'NRG_Rep__c, Product__c, Potential_Deal_Size__c, Line_Description__C, Notes_from_NRG_on_opportunity__C,'+
        	'Description, Latest_updates__c, lastactivitydate FROM Lead'
        );
    }
        
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        List<Account> accounts = [Select Name, ownerid from Account ];
        List<Account> newAccounts = new List<Account>();
        for (Lead lead : scope) {
            boolean flag = false;
            for(Account acc: accounts){
                if(acc.Name.trim().equals(lead.Company.trim())){
                    flag = true;
                    break;
               }
            }
            if(!flag) {
                Account account = new Account();
                account.Name = lead.Company;
                account.OwnerId = lead.OwnerId;
                newAccounts.add(account);     
                recordsProcessed = recordsProcessed + 1;
            }
        }
        try {
        	insert newAccounts;
        } catch(Exception e) {
			system.debug(e);
        }
    }    
        
    global void finish(Database.BatchableContext bc){
        //ContactBatchClass myBatchObject = new ContactBatchClass(); 
		//Id batchId = Database.executeBatch(myBatchObject, 1);
        System.debug(recordsProcessed + ' records processed. Account!');
    }    
}