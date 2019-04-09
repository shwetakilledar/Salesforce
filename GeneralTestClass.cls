public class GeneralTestClass {
    
    public void mainMethod(){
        System.debug('Here');
        List<Contact> contacts = [Select FirstName, LastName, AccountId from contact];
        
        Map<Id, String> oppConMap = new Map<Id,String>();
        Map<Id, String> oppAccMap = new Map<Id,String>();
		Set<String> setAcc = new Set<String>();  
        List<Account> a = new List<Account>();
        
        List<Account> accIdList = new List<Account>();
        
        for(Contact co:contacts){
            if(!oppConMap.containsKey(co.AccountId)){
                oppConMap.put(co.AccountId,co.FirstName+'_'+co.LastName);
            }
        }
        
        for(Account ac:[Select Id, Name from Account]){
            if(!oppConMap.containsKey(ac.Id)){
                a.add(ac);
                setAcc.add(ac.Name);
            }
        }
        
        List<Lead> leads = [Select Id,Company, FirstName, LastName, Email, Title, Phone from Lead];
		List<Lead> noContactLeads = new List<Lead>();
		List<Lead> noContactAcc = new List<Lead>();

        for(Lead l: leads){
            if(setAcc.contains(l.Company) && String.isBlank(l.FirstName) && l.LastName.equals('n/a') || l.LastName.equals('TBD') || l.LastName.equals('N/A') || l.LastName.equals('[not provided]') && String.isBlank(String.valueOf(l.Email)) && String.isBlank(l.Title) && String.isBlank(String.valueOf(l.Phone))){
                noContactLeads.add(l);
            }
        }
	
        Integer i = 0;
       
        for(Lead lead : noContactLeads){
            lead.LastName = lead.LastName + '_' + String.valueOf(i);
            i++;
         }
        
        try{
        	update noContactLeads;  
            System.debug('Updated');
        }catch(Exception e){
            System.debug(e);
        }
        
       
        
     }
    
}