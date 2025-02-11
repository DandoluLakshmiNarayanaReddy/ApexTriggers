public class AccountTriggerHandler {
    public static void CreateAccountsafter(List<Account> accs)
    {
        List<Contact> contacts=new List<Contact>();
        for(Account acc:accs)
        {
            if(acc.Number_of_Contacts__c!=NULL)
            {
                for(Integer i=1;i<=acc.Number_of_Contacts__c;i++)
                {
                    Contact c=new Contact();
                    c.LastName=acc.Name + '-'+ i;
                    c.AccountId=acc.Id;
                    contacts.add(c);
                }
            }
        }
        if(!contacts.isEmpty())
        {
            System.debug(contacts.size());
             Insert contacts;
        }
       
    }
    
    public static void CreateAccounts(List<Account> accs)
    {
        for(Account a:accs)
        {
            if(a.ShippingState!=a.BillingState)
            {
                a.ShippingState = a.BillingState;
            }
            if(a.Industry=='Agriculture' && a.Type=='Installation Partner')
            {
                if(a.Ownership=='Private')
                {
                    a.addError('Ownership cannot be private');
                }
                
            }
            
        }
        
    }
    public static void CreateAccountsafter(List<Account> accs,Map<Id,Account> Oldmap)
    {
        Map<Id,String> accountstobeupdated=new Map<Id,String>();
        List<Id> accountidstobeupdated=new List<Id>();
        for(Account a:accs)
        {
            if(Oldmap.get(a.Id).Website!=a.Website)
            {
                accountstobeupdated.put(a.Id,a.Website);
                accountidstobeupdated.add(a.Id);
            }
        }
        if(accountstobeupdated.keySet().size() > 0)
        {
            List<Contact> contoupdate=new List<Contact>();
            List<Contact> contacts=[SELECT Id,AccountId,Name,Website__c FROM Contact WHERE AccountId IN :accountstobeupdated.keySet()];
            for(Contact con:contacts)
            {
                con.Website__c=accountstobeupdated.get(con.Id);
                contoupdate.add(con);
            }
            if(contoupdate.size()>0)
            {
               
                Update contoupdate;
            }
            
        }
        
    }
    
    
    

}