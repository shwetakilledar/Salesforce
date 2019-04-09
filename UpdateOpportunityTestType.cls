@isTest
public class UpdateOpportunityTestType {
	static testmethod void test() {
    	List<Opportunity> op = new List<Opportunity>();
        
         for (Integer i=0;i<200;i++) {
            Opportunity o = new Opportunity(
            	    		OwnerId = '005j000000BCElWAAX',       
                            NRG_Solutions_Rep__c = 'Andrew Pearce',
                            NRG_Solutions_Product__c = 'CHP',
                            CloseDate = Date.newInstance(2019, 12 , 31),
                            Name = 'Test - Solutions Opportunity' + i,
                            Type = 'NRG Solution',
                            Reason_s_for_Stage_Change__c = 'Other',
                            StageName = 'Open'   
                );
            op.add(o);
        }
        
        try{
        	insert op;    
        }catch(Exception e){
            System.debug(e);
        }
       	
       	
       
        Test.startTest();
        //Call Contact
        UpdateOpportunityType c = new UpdateOpportunityType();
       	c.updateOpp();
        Test.stopTest();
        
        // Verify accounts updated
        Opportunity[] oppo = [SELECT Id, Type FROM Opportunity];
        System.assert(oppo[0].Type.Contains('NRG Solutions'));
        System.debug(oppo[0].Type.Contains('NRG Solutions'));
    	
	}
}