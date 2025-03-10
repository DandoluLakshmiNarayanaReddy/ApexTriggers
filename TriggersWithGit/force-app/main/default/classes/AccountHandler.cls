public class AccountHandler {


//     On Account, there’s a checkbox field "Close_Good_Opportunities__c"
// 🔹 When checked, all related Opportunities with a probability > 70% should be automatically closed

// Sounds simple? But how would you handle bulk processing efficiently? 🤔
public static boolean isExecuted = false;

    public static void AfterUpdateCloseOpp(List<Account> newRecords) {
        List<Opportunity> toUpdateOpp=new List<Opportunity>(); 
        if(!isExecuted)
        {
            isExecuted=True;


           Set<Id> accIds=new Set<Id>();
            for(Account acc:newRecords)
            {
                if(acc.CloseGoodOpportunities__c==TRUE)
                {
                    accIds.add(acc.Id);
                }
            }
        }
        List<Opportunity> Opts=[SELECT ID,NAME,AccountId,Probability,StageName FROM Opportunity WHERE AccountId IN: accIds];
        for(Opportunity opt:Opts)
        {
            if(opt.Probability>70)
            {
                opt.StageName='Closed Won';
            }
            toUpdateOpp.add(opt);
        }
        if(toUpdateOpp.size()>0)
        {
            Update toUpdateOpp;
        }
    }

    //If there are any related contacts, account cant be deleted
    public static void BeforeDeleteAddError(Map<Id,Account> OldMap){
        
       List<Account> cLists=[SELECT Id,Name FROM Account WHERE Id IN:OldMap.keySet()];
       Map<Id, Contact> Cons=New Map<Id,Contact>([SELECT Id,Name,AccountId FROM Contact WHERE AccountId IN:OldMap.keySet()]);
       Map<Id,Contact> acidvsCons=new Map<Id,Contact>();
       for(Contact con:Cons.values())
       {
        acidvsCons.put(con.AccountId,con);
       }
       for(Account ac : cLists)
         {
             if(acidvsCons.containsKey(ac.Id))
            {
                ac.addError('Account notPbe deleted');
            }
        }
    //    Map<Id,Contact> MapCons=new Map<Id,Contact>([SELECT Id,Name FROM Contact WHERE AccountId IN:OldMap.keySet()]);
    //     for(Account ac:OldMap.values())
    //     {
    //        if(MapCons.containsKey(ac.Id))
    //        {
    //          ac.addError('Account notPbe deleted');
    //        }
    //     }
        

    }
}