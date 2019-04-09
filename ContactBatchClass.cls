global class ContactBatchClass implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Company, OwnerId, Name, FirstName, LastName, Email,'+
            'Phone, Title, Status, Reason_for_state_change__c , State_Change_Description__c, '+
            'NRG_Rep__c, Product__c, Potential_Deal_Size__c, Line_Description__C, Notes_from_NRG_on_opportunity__C,'+
            'Description, Latest_updates__c, lastactivitydate, LastModifiedDate FROM Lead '
        );
    }
        
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        List<Account> accounts = [Select Name, ownerid from Account ];
        List<Contact> contacts = [Select FirstName, LastName, Title, Email, Phone, Accountid from Contact];
        
        List<Contact> newContacts = new List<Contact>();
        for (Lead lead : scope) {
            Id accId;
            for(Account acc: accounts){
                if(acc.Name.trim().equals(lead.Company.trim())){
                    accId = acc.Id;
                    break;
                }
            }
            
            if(!String.isBlank(String.valueOf(accId))) {
                boolean flag = false;
                System.debug('accId: ' + String.valueOf(accId));
                for(Contact cont: contacts) {
                    if(((String.isNotBlank(lead.FirstName) && lead.FirstName.equals(cont.FirstName)) || String.isBlank(lead.FirstName)) && 
                       ((String.isNotBlank(lead.LastName) && lead.LastName.equals(cont.LastName)) || String.isBlank(lead.LastName)) &&
                       ((String.isNotBlank(String.valueOf(lead.Email)) && lead.Email.equals(cont.Email)) || String.isBlank(String.valueOf(lead.Email))) && 
                       ((String.isNotBlank(String.valueOf(lead.Phone)) && lead.Phone.equals(cont.Phone)) || String.isBlank(String.valueOf(lead.Phone))) && 
                       ((String.isNotBlank(lead.Title) && lead.Title.equals(cont.Title)) || String.isBlank(lead.Title))) {
                           flag = true;
                           break;
                    }
                }
                if(!flag) {
                    Contact contact = new Contact();
                    contact.FirstName = lead.FirstName;
                    contact.LastName = lead.LastName;
                    contact.Email = lead.Email;
                    contact.Phone = lead.Phone;
                    contact.Title = lead.Title;
                    contact.AccountId = accId;
                    contact.OwnerId = lead.OwnerId;
                    newContacts.add(contact);
                }
            }    
        }
            
        try {
            insert newContacts;
        } catch(Exception e) {
            system.debug(e);
        }
    }    
        
    global void finish(Database.BatchableContext bc){
        List<Lead> scope = [ SELECT Id, Company, OwnerId, Name, FirstName, LastName, Email, Phone, 
                             Title, Status, Reason_for_state_change__c , State_Change_Description__c, 
                             NRG_Rep__c, Product__c, Potential_Deal_Size__c, Line_Description__C, 
                             Notes_from_NRG_on_opportunity__C, Description, Latest_updates__c, lastactivitydate ,LastModifiedDate
                            FROM Lead ];
        
        Map<String, String> compLatestUpdateMap = new Map<String, String>();
        Map<String,Datetime> lastUpdateMap = new Map<String,Datetime>();
        Map<String, String> contIdMap = new Map<String, String>();
        
        for(Lead lead: scope){
            if(lastUpdateMap.containsKey(lead.Company.trim())) {
                 if(lead.LastModifiedDate > lastUpdateMap.get(lead.Company)) {
                    lastUpdateMap.put(lead.Company, lead.LastModifiedDate);
                    compLatestUpdateMap.put(lead.Company, lead.Latest_Updates__c );
                    contIdMap.put(lead.Company, lead.FirstName+'_'+lead.LastName+'_'+lead.Email+'_'+lead.Phone+'_'+lead.Title); 
                }
            } else {
                lastUpdateMap.put(lead.Company, lead.LastModifiedDate);
                compLatestUpdateMap.put(lead.Company, lead.Latest_Updates__c );
                contIdMap.put(lead.Company, lead.FirstName+'_'+lead.LastName+'_'+lead.Email+'_'+lead.Phone+'_'+lead.Title); 
            }
        }   
        
        System.debug('kkkkk'+lastUpdateMap);
        System.debug('kkkkk'+compLatestUpdateMap);
        System.debug('kkkkk'+contIdMap);
        
       //OpportunityBatchClass myBatchObject = new OpportunityBatchClass(compLatestUpdateMap, contIdMap, lastUpdateMap); 
       //Id batchId = Database.executeBatch(myBatchObject, 1);
        System.debug(recordsProcessed + ' records processed. Contact!');
    }    
}