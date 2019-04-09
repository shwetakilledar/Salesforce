@isTest
Private class DeleteDuplicateAccountsTestClass {
	static testMethod void test() {
        List<Account> acc = new List<Account>();
        List<Account> newAcc = new List<Account>();
        for (Integer i=0;i<100;i++) {
            Account a = new Account(Name = 'TestCompany' + i, OwnerId = '005f100000FoZoPAAV');
            acc.add(a);
        }
        
        insert acc;
        
        for (Integer i=0;i<20;i++) {
            Account a = new Account(Name = 'TestCompany' + i, OwnerId = '005f100000FoZoPAAV');
            newAcc.add(a);
        }
        
        insert newAcc;
        
        DeleteDuplicateAccounts d = new DeleteDuplicateAccounts();
        d.mainMethod();
    }
}