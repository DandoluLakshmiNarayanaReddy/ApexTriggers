public with sharing class TaskTriggerHandler {

    public static Set<Id> setExecutedRecord = new Set<Id>();

    public static boolean isExecuted = false;
    
    // When all Tasks associated with an Opportunity are marked as ‘Completed’ 
    //and there are no Tasks in other statuses like ‘In Progress,’ ‘Not Started,’, ‘Deferred,’ or 'Waiting on someone else' the 
    // Opportunity Stage should automatically update to ‘Closed Won.’
    public static void AfterUpdate(List<Task> newRecords, Map<Id,Task> oldMap) {

       
        
        Set<Id> OpIds=new Set<Id>();
         if(!isExecuted)
        {
            isExecuted=True;
      
            for(Task t:newRecords)
            {
                    if(t.Status == 'Completed' && oldMap.get(t.Id).Status!=t.Status){
                        if(t.WhatId.getSObjectType() == Opportunity.SObjectType){
                            OpIds.add(t.WhatId);
                        }
                    }
            }
        }
        List<Opportunity> lops=[SELECT Id,Name,StageName,(SELECT Id,Status,WhatId FROM Tasks) FROM Opportunity WHERE Id IN:OpIds];
        List<Task> tsks=[Select Id,Status,WhatId FROM Task WHERE WhatId IN:OpIds];
        Map<Id,List<String>> IdvsTasks=new Map<Id,List<String>>();
        for(Task t:tsks)
        {
             if(!IdvsTasks.containsKey(t.WhatId))
             {
              
                IdvsTasks.put(t.WhatId,new List<String>{t.status});
             }
             IdvsTasks.get(t.WhatId).add(t.Status);   
        }
     
        List<Opportunity> lopsToUpdate=new List<Opportunity>();
        for(Opportunity op:lops)
        {
            boolean allCompleted = false;
            if(!IdvsTasks.get(op.Id).Contains('Completed')){
                allCompleted = false;
            }else if(!IdvsTasks.get(op.Id).Contains('In Progress') && !IdvsTasks.get(op.Id).Contains('Waiting on someone else') && !IdvsTasks.get(op.Id).Contains('Not Started') && !IdvsTasks.get(op.Id).Contains('Deferred')){
                allCompleted = true;
            }
            if (allCompleted == true){
                op.StageName = 'Closed Won';       
            }
            lopsToUpdate.add(op);       
        }
        if(lopsToUpdate.size()>0)
        {
            update lopsToUpdate;
        }
       
    }

//     Write a trigger on the Task object that automatically updates the parent Account's Rating field.

// Requirements:
// When a Task is completed (Status = Completed), check its related Account.
// Update the Account's Rating field to:
// - Hot if the Task's Priority is "High."
// - Warm if the Task's Priority is "Normal."
// - Cold if the Task's Priority is "Low."


    public static void UpdateAccountRating(List<Task> newRecords, Map<Id,Task> OldMap)
    {

        Map<Id,String> acIdVSPr=new Map<Id,String>();
        if(!isExecuted)
        {
            isExecuted=True;
            Set<Id> AcIds=new Set<Id>();
           
            for(Task t:newRecords)
            {
                if(String.valueOf(t.WhatId).startsWith('001'))
                {
                    if(t.WhatId!=NULL && t.Status=='Completed')
                    {
                        System.debug('whatidadded');
                        AcIds.add(t.WhatId);
                        acIdVSPr.put(t.WhatId,t.Priority);
                    }
               }
            
            }
        }
        List<Account> accs=[SELECT Id,Name,Rating FROM Account WHERE Id IN:acIdVSPr.keySet()];
        List<Account> accsTOUpdate=new List<Account>();
        Set<Id> executedIds=new Set<Id>();
        for(Account ac:accs)
        {
            System.debug('has accts');
            if(acIdVSPr.get(ac.Id)=='High')
            {
                ac.Rating='Hot';
            }
           else if(acIdVSPr.get(ac.Id)=='Normal')
            {
                ac.Rating='Warm';
            }
           else
            {
                ac.Rating='Cold';
            }
            
                accsTOUpdate.add(ac);
        }
        if(accsTOUpdate.size()>0)
        {
            System.debug('Executed');
            update accsTOUpdate;
        }
        



    }
} 