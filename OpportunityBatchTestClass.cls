@isTest
public class OpportunityBatchTestClass {
	
    static testmethod void test() {
    
    // Create test accounts to be updated
    // by the batch job.

        List<Lead> leadList = new List<Lead>();
        List<Account> ac = new List<Account>();
        
       
        
        for (Integer i=0;i<200;i++) {
            Lead l = new Lead( FirstName = 'TestFirstName' + i,
                			  LastName = 'TestLastName' + i,
                              Company= 'TestCompany'+i,
                              Product__c='CHP',
                              Status='Open', 
                              Campaign__c='Healthcare',
                              OwnerId='005j000000BCElWAAX',
                              Reason_for_state_change__c = 'Other',
                              NRG_Rep__c = 'Sarah Devon',
                              Potential_Deal_Size__c = 0,
                              Notes_from_NRG_on_opportunity__C = 'Nothing',
                              Latest_updates__c='Call them');
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
        
        List<Lead> scope = [SELECT Id, Company, OwnerId, Name, FirstName, LastName, Email, Phone, 
                             Title, Status, Reason_for_state_change__c , State_Change_Description__c, 
            				 NRG_Rep__c, Product__c, Potential_Deal_Size__c, Line_Description__C, 
                             Notes_from_NRG_on_opportunity__C, Description, Latest_updates__c, lastactivitydate ,LastModifiedDate
                            FROM Lead ];
        
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
       	
       
        List<Account> newAc = [Select Name from Account];
        System.debug('Added accounts');
        
        Test.startTest();
        SYstem.debug('In test'+newAc[0]);
        
        
        
         List<Lead> scope1 = [ SELECT Id, Company, OwnerId, Name, FirstName, LastName, Email, Phone, 
                             Title, Status, Reason_for_state_change__c , State_Change_Description__c, 
            				 NRG_Rep__c, Product__c, Potential_Deal_Size__c, Line_Description__C, 
                             Notes_from_NRG_on_opportunity__C, Description, Latest_updates__c, lastactivitydate ,LastModifiedDate
                            FROM Lead ];
        
        Map<String, String> compLatestUpdateMap = new Map<String, String>();
        Map<String,Datetime> lastUpdateMap = new Map<String,Datetime>();
        Map<String, String> contIdMap = new Map<String, String>();
        
        for(Lead lead: scope1){
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
        
        
        
        
        //Call Contact
        OpportunityBatchClass c = new OpportunityBatchClass(compLatestUpdateMap, contIdMap, lastUpdateMap);
       	Database.executeBatch(c);
        Test.stopTest();
        
        // Verify accounts updated
        Opportunity[] accUpdatedList = [SELECT Name FROM Opportunity];
       	System.assert(accUpdatedList[0].Name.Contains('TestCompany'));
        
    	
	}

}