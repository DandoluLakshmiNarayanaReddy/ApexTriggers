public with sharing class OpportunityTriggerHandler {

  public static boolean isExecuted = false;
    // When an Opportunity’s Stage changes:
    // 🔹 If Stage = "Closed Won", update all related Tasks' Status to "Completed".
    // 🔹 If Stage = "Closed Lost", update all related Tasks' Status to "In Progress". 
    public static void AfterUpdate(List<Opportunity> newopprecords, Map<Id,Opportunity> oldmap) {


      Set<Id> oppids=new Set<Id>();
      if(!isExecuted)
      {
          isExecuted=True;
 
         
          
            for(Opportunity opp:newopprecords)
            {
                if(opp.StageName=='Closed Won' || opp.StageName=='Closed Lost')
                {
                  oppids.add(opp.Id);
                }
          }
          }
        List<Task> tasks=[Select Id,status, WhatId FROM Task Where WhatId IN: oppids];
        Map<Id,Opportunity> oppmap=new Map<Id,Opportunity>([Select Id,StageName FROM Opportunity Where Id IN: oppids]);
        List<Task> Updatedtasks=new List<Task>();
        for(Task t:tasks)
        {
            String stagename=String.valueOf(oppmap.get(t.WhatId).StageName);
              if(stagename =='Closed Won')
              {
                t.Status='Completed';
              }
              if(stagename =='Closed Lost')
              {
                t.Status='In Progress';
              }
              Updatedtasks.add(t);
           
        
        }
        if(Updatedtasks.size()>0)
        {
            Update Updatedtasks;
        }
      }
      // Write a trigger to autopopulate a customfield total opportunities on account when related opportunities changes?’

      public static void AfterUpdate(List<Opportunity> newRecords)
      {
        Set<Id> opIds=new Set<Id>();
        Set<Id> AccIds=new Set<Id>();
        if(!isExecuted)
        {
            isExecuted=True;

         
          Map<Id,List<Opportunity>> MapofOps=new Map<Id,List<Opportunity>>();
            for(Opportunity op:newRecords)
            {
              opIds.add(op.Id);
              AccIds.add(op.AccountId);

            }
          }
          List<Account> acc=[SELECT Id,Name,TotalOps__c,(SELECT Id,Name,AccountId FROM Opportunities) FROM Account WHERE Id IN :AccIds];
         
          for(Account ac:acc)
          {
             Decimal totalAmount = 0;
                  for (Opportunity opportunity : ac.Opportunities) {
                        totalAmount ++;
                    }
            ac.TotalOps__c = String.valueOf(totalAmount);
          }
         Update acc;
       

        ////OROROROROROR This is suing A map that has AccountId and List of Opportunities
 
    //     List<Account> accs=[SELECT Id,Name,TotalOps__c FROM Account WHERE Id IN :AccIds];
    //     List<Opportunity> allLists=[SELECT Id,AccountId,Name FROM Opportunity WHERE AccountId IN:AccIds];
    //    // Map<Id,List<Opportunity>> MapofOps=new Map<Id,List<Opportunity>>(SELECT Id,Name,TotalOps__c,(SELECT Id,Name,AccountId FROM Opportunities) FROM Account WHERE Id IN :AccIds]);
    //    for (Opportunity opp : allLists) {
    //     if (!MapofOps.containsKey(opp.AccountId)) {
    //         // If the AccountId is not already in the map, create a new list
    //         MapofOps.put(opp.AccountId, new List<Opportunity>());
    //     }
    //     // Add the Opportunity to the list for the corresponding AccountId
    //     MapofOps.get(opp.AccountId).add(opp);
    // }

    // for(Account ac:accs)
    // {
    //   ac.TotalOps__c=String.valueOf(MapofOps.get(ac.Id).size());
    // }
    // Update accs;

    //   }

        }

//         You’ve got a multi-select picklist on 'Account' as well as 'Opportunity' with values: A, B, C, D, E, F.

// Your task? 🕵️‍♂️
// 💡 Ensure that whenever an Opportunity is inserted or updated, the corresponding Account picklist updates to reflect the same values.

        public static void AfterUpdatePickList(List<Opportunity> newRecords)
        {
          Set<Id> AccIds=new Set<Id>();
          Map<Id,Opportunity> MapOps=new Map<Id,Opportunity>();
          for(Opportunity opp:newRecords)
          {
            AccIds.add(opp.AccountId);
            //if(MapOps.containsKey(opp.AccountId)
              MapOps.put(opp.AccountId,opp);
          
          }
          List<Account> AccLists=[SELECT Id,Name FROM Account WHERE Id IN:AccIds];
          List<Account> AccsTOUpdate=new List<Account>();
          for(Account acc:AccLists)
          {
            acc.ValueOptions__c=MapOps.get(acc.Id).ValueOptions__c;
            AccsTOUpdate.add(acc);
          }
          
         update AccsTOUpdate;
        }
         //Implement an apex Trigger to prevent the deletion of an Opportunity if it has any related Activities.

        public static void BeforeDelete(List<Opportunity> newRecords)
        {
          
          Set<Id> opIds=new Set<Id>();
          for(Opportunity op:newRecords)
          {
            opIds.add(op.Id);
          }
          List<Opportunity> ops=[Select Id,Name,(Select Id,Subject,status FROM Tasks),(Select Id FROM Events) FROM Opportunity WHERE ID IN:opIds];
          Map<Id, Boolean> opportunityHasActivities = new Map<Id, Boolean>();
          for(Opportunity op:newRecords)
          {
            if(!op.Events.isEmpty() || !op.Tasks.isEmpty())
            {
              opportunityHasActivities.put(op.Id,true);
            }
          }
          for(Opportunity op:newRecords)
          {
            if(opportunityHasActivities.containsKey(op.Id))
            {
              op.addError('opp no delete');
            }
          }


          
        }
}