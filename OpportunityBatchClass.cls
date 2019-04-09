global class OpportunityBatchClass implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Map<String, String> map1;
    global Map<String, String> map2;
    global Map<String, Datetime> map3;
        
    global OpportunityBatchClass(Map<String, String> map1, Map<String, String> map2, Map<String, Datetime> map3) {
    	this.map1 = map1;
		this.map2 = map2;
        this.map3 = map3;
    }
        
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
       	List<Opportunity> newOpportunityList = new List<Opportunity>();
        List<Account> accounts = [Select Id, Name from Account];
        List<Opportunity> opportunities = [Select Accountid from Opportunity];
        List<String> oppoIds = new List<String>();
        
        for(Opportunity oppo: opportunities){
        	oppoIds.add(String.valueOf(oppo.accountid));    
        }       
      	
        List<Contact> contacts = [Select Id, Accountid, LastModifiedDate, FirstName, LastName, Email, Phone, Title from Contact];
        List<String> contAccIds = new List<String>();
        Map<String,Id> contIdMap = new Map<String,Id>();
        for (Contact contact: contacts) {
            contIdMap.put(contact.FirstName+'_'+contact.LastName+'_'+contact.Email+'_'+contact.Phone+'_'+contact.Title, contact.Id);
            contAccIds.add(String.valueOf(contact.AccountId));
        }
        
       /*
        for(Lead lead: scope){
            if(lastUpdateMap.containsKey(lead.Company)) {
                System.debug('pppppBlank');
               	 if(lead.LastModifiedDate > lastUpdateMap.get(lead.Company)) {
                    System.debug('////////'+lead.LastModifiedDate+lastUpdateMap.get(lead.Company));
                    lastUpdateMap.put(lead.Company, lead.LastModifiedDate);
                    compLatestUpdateMap.put(lead.Company, lead.Latest_Updates__c );
                    
                }
               
            } else {
                System.debug('heretttyyy'+lead.LastModifiedDate+lastUpdateMap.get(lead.Company));
                lastUpdateMap.put(lead.Company, lead.LastModifiedDate);
                compLatestUpdateMap.put(lead.Company, lead.Latest_Updates__c );
            }
        }
        	
       	  
         for (Contact contact: contacts) {
            List<Account> a = [Select Name from Account where id = :contact.accountId ];
            
             contIdMap.put(a[0].Name,contact.Id);
            contAccIds.add(String.valueOf(contact.AccountId));
           }
     	
        System.debug('kkkkk'+lastUpdateMap);
        System.debug('kkkkk'+compLatestUpdateMap);
       System.debug('kkkkk'+contIdMap);
        
        */
        System.debug('Map1'+Map1);
        System.debug('Map2'+Map2);
        System.debug('Map3'+Map3);
        System.debug('leads'+scope);
        System.debug('jjj'+accounts[0]);
        for (Lead lead : scope) {
            for (Account acc: accounts) {
             
              
                if(acc.Name.trim().equals(lead.Company.trim()) && contAccIds.contains(String.valueOf(acc.Id)) 
                  && !oppoIds.contains(String.valueOf(acc.Id)) && lead.LastModifiedDate == map3.get(lead.Company)) {
                   			
                            Opportunity opportunity = new Opportunity();
                            opportunity.AccountId = acc.Id;
                            opportunity.OwnerId = lead.OwnerId;               
                            opportunity.Stage_Change_Description__c = lead.State_Change_Description__c;                     
                            opportunity.NRG_Solutions_Rep__c = lead.NRG_Rep__c;
                            opportunity.NRG_Solutions_Product__c = lead.Product__c;
                            opportunity.Line_Description__c = lead.Line_Description__c;      
                            opportunity.Potential_Deal_Size__c = lead.Potential_Deal_Size__c;
                            opportunity.Latest_Updates__c = map1.get(acc.Name);
                            opportunity.Description = lead.Description;
                            opportunity.CloseDate = Date.newInstance(2019, 12 , 31);
                            opportunity.Name = lead.Company.trim() +' - Solutions Opportunity';
                            opportunity.Type = 'NRG Solution';
                            opportunity.Reason_s_for_Stage_Change__c = lead.Reason_for_state_change__c;
                            opportunity.Contact__c = contIdMap.get(map2.get(acc.Name));
                            
                            if(!String.isBlank(lead.Status)){
                                 if(lead.Status.toLowerCase().equals('open')){
                                     opportunity.StageName= lead.Status;
                                 }else if(lead.Status.toLowerCase().equals('disqualified')){
                                     opportunity.StageName = lead.Status;
                                 }else if(lead.Status.toLowerCase().equals('review')){
                                     opportunity.StageName= 'Engaged';
                                 }else if(lead.Status.toLowerCase().contains('awarded')){
                                     opportunity.StageName= 'Closed Won';
                                 }else if(lead.Status.toLowerCase().contains('qualified')){
                                     opportunity.StageName = 'Data Exchanged/Qualified';
                                 }else if(lead.status.toLowerCase().contains('nrg')){
                                     opportunity.StageName = 'Contracting';
                                 }else if(lead.Status.toLowerCase().contains('hold')){
                                     opportunity.StageName = 'On Hold';
                                 }
                            }else{
                              
                                opportunity.StageName = 'Open';    
                            }
                            
                    newOpportunityList.add(opportunity);    
                      
                                  
                }
            }
        }
            
        try {
        	insert newOpportunityList;
        } catch(Exception e) {
			system.debug('here is an exception'+e);
        }
    }    
        
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Opportunity!');
    }    
}