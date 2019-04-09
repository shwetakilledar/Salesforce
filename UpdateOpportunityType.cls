public class UpdateOpportunityType {
	
    public void updateOpp(){
        List<Opportunity> opp = [select Id, Type from Opportunity];
        Integer i=0;
        for(Opportunity op:opp){
            if(op.Type == 'NRG Solution'){
               	op.Type = 'NRG Solutions';
                i++;
            }
        }
         System.debug('I am here'+ i);
        
        try{
            update opp;
        }catch(Exception e){
            System.debug(e);
        }
  	}
}