public class TriggerHandlerOnOpportunity {
    
    public static void TriggerHandlerOpportunityNotifyEveryone(List<Opportunity> opps,Map<Id,Opportunity> oldmaprecs){
        
        
        
        //fetch users, opportunity owner,Accountowner,oportunityteammembers and peoplefrom the public group
       Set<Id> listofUsers=new Set<Id>();
         List<Id> Accids=new List<Id>();
        List<Id> oppids=new List<Id>();
        List<Id> Gmids=new List<Id>();
        for(Opportunity opp:opps)
        {
            if(opp.StageName=='Closed Won' && oldmaprecs.get(opp.Id).Stagename!=opp.StageName)
            {
                
                Accids.add(opp.AccountId);
                oppids.add(opp.Id);
            }
        }
                List<GroupMember> Megastargroupmem=[SELECT Id,UserorGroupId FROM GroupMember WHERE Group.Name=:'Megastargroup'];

        for(GroupMember GM:Megastargroupmem)
        {
             
                Gmids.add(GM.UserorGroupId);
                
            
        }
        
         List<Account> accs=[SELECT Id,OwnerId FROM Account WHERE Id IN:Accids];
         List<OpportunityTeamMember> OpTMs=[SELECT Id,UserId,OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN:oppids];        
        
        for(Opportunity opp:opps)
        {
            if(opp.StageName=='Closed Won' && oldmaprecs.get(opp.Id).Stagename!=opp.StageName)
            {
                listofUsers.addAll(Gmids);
                listofUsers.add(opp.OwnerId);
                  for(Account acc:accs)
                    {
                        if(acc.Id==opp.AccountId)
                        listofUsers.add(acc.OwnerId);
                    }
                  for(OpportunityTeamMember OpTM:OpTMs)
                    {
                        if(opp.Id==OpTM.OpportunityId)
                        listofUsers.add(OpTM.UserId);
                    }
                            
            }
        }
        //Map<Id,Account> Mapofaccs=new Map<Id,Account>([SELECT Id,OwnerId FROM Account WHERE Id IN:Accids]);
       if(!listofUsers.isEmpty())
       {
           
           List<String> useremaillist=new List<String>();
           List<User> userrecs=[SELECT Id,Email FROM User WHERE Id IN:listofUsers];
           for(User userrec:userrecs)
           {
               useremaillist.add(userrec.Email);
           }
               Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                message.toAddresses = useremaillist;
               
                message.subject = 'Notifying users';
                message.plainTextBody = 'Opportunity is closed Won';
                Messaging.SingleEmailMessage[] messages = 
                    new List<Messaging.SingleEmailMessage> {message};
                         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
       }
        
         
    }
    
    
    
    
    
    
    
    public static void TriggerHandlerOpportunityAfterUpdate(List<Opportunity> opps){
        List<Id> oppIds=new List<Id>();
         List<OpportunityTeamMember> teammembertoadded=new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> OpportunityTeamMemberdeletelist=new List<OpportunityTeamMember>();
        for(Opportunity op:opps)
            {
                oppIds.add(op.Id);
            }
        List<OpportunityTeamMember> OTM= [SELECT Id,Name,OpportunityId FROM OpportunityTeamMember Where OpportunityId IN :oppIds];
        
        List<Task> taskrec=new List<Task>();
        for(Opportunity opp:opps)
            {
                if(opp.StageName=='Closed Won')
                {
                    Task t=new Task();
                    t.Subject='Split Revenue';
                    t.Priority='High';
                    t.Status='Not started';
                    t.WhatId=opp.Id;
                    t.Description='Please Split the revenue';
                    t.OwnerId=opp.OwnerId;
                    taskrec.add(t);
                    
                    
                    
                    
                    
                    
                    
                    
                }
                else if(opp.StageName=='Closed Lost')
                {
                    for(OpportunityTeamMember teammember:OTM)
                    {
                        if(teammember.OpportunityId==opp.Id)
                        {
                            OpportunityTeamMemberdeletelist.add(teammember);
                        }
                    }
                    
                }
                else if(opp.StageName=='Needs Analysis')
                {
                    List<User> userofopportunists=[SELECT Id,Name,UserRole.Name FROM User Where UserRole.DeveloperName='Opportunists'];
                   
                    
                    for(Opportunity op:opps)
                     {
                        for(User user:userofopportunists)
                        {
                                OpportunityTeamMember teammember=new OpportunityTeamMember();
                                teammember.UserId=user.Id;
                                teammember.OpportunityId=op.Id;
                                teammember.TeamMemberRole='Account Manager';
                                teammember.OpportunityAccessLevel='Edit';
                                teammembertoadded.add(teammember);
                            
                        }
                        
                         
                     }
                    
                }
                
                
                
            }
                if(taskrec.size()>0)
                {
                    insert taskrec;    
                }
               if(OpportunityTeamMemberdeletelist.size()>0)
                {
                    Delete OpportunityTeamMemberdeletelist;    
                }
                 if(teammembertoadded.size()>0)
                {
                    Insert teammembertoadded;    
                }
        
        
        }
        

   

   
public static void TriggerHandlerOpportunityAfterDelete(List<Opportunity> opps)
    {
       
         List<Task> taskrec=new List<Task>();
        for(Opportunity opp:opps)
        {
            Task t=new Task();
             t.Subject='Follow up on why Opp is getting deleted';
             t.Priority='High';
              t.Status='Not started';
             //t.WhatId=opp.Id;
              t.Description='Please Split the revenue';
              t.OwnerId=opp.OwnerId;
               taskrec.add(t);
        }
        If(!taskrec.isEmpty())
        {
            insert taskrec;
        }
        
    }
     public static void TriggerHandlerOpportunityBeforeUpdate(List<Opportunity> newopps, Map<Id,Opportunity> Oldopps)
     {
         for(Opportunity newopp:newopps)
         {
            if(Oldopps.get(newopp.Id).StageName!=newopp.StageName)
            {
                 newopp.Amount=(newopp.Probability*newopp.ExpectedRevenue);
            }
                
         }
     }

}