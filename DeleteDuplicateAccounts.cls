public class DeleteDuplicateAccounts {
    
    public void mainMethod(){
        
	  	List<Account> allAccounts = [SELECT Id, Name FROM Account];
      //  List<Opportunity> opp = [Select accountId from Opportunity Limit 500];
        Set<String> accountNames = new Set<String>();
        List<Account> accountsToDelete = new List<Account>();
      //  List<Opportunity> oppToDelete = new List<Opportunity>();
        System.debug('here'+allAccounts[0]+allAccounts[100]);
        for (Account a : allAccounts) {
            //System.debug(a.Name);
            
            if (accountNames.contains(a.Name)) {
                
                accountsToDelete.add(a);
               // for (Opportunity o: opp) {
               //     if(String.valueOf(a.id).equals(String.valueOf(o.accountId))) {
               //        accountsToDelete.add(a);
               //   }
            }
            else {
                accountNames.add(a.Name);
            }
          }
            
        
        System.debug(accountsToDelete);
		delete accountsToDelete;
        System.debug('here');
    }
}