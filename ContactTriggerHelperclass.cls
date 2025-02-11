public class ContactTriggerHelperclass {
    
    
     public static void CreateNLocations(List<Contact> newrecords, Map<Id,Contact> oldrecords)
     {
        List<Location__c> locationstoadd=new List<Location__c>();
         List<Location__c> locationstodelete=new List<Location__c>();
         Map<Id,Location__c> locationsupdated;
         if(oldrecords!=null)
         {
          locationsupdated=new Map<Id,Location__c>([SELECT Id,Contact__c FROM Location__c WHERE Contact__c IN :oldrecords.keySet()]);
 
         }
         for(Contact c:newrecords)
         {
             if(Trigger.isInsert)
             {
                 for(Integer i=0;i<c.Create_N_Locations__c;i++)
                 {
                     Location__c l=new Location__c();
                     l.Name='Commerce'+i;
                     l.Contact__c=c.Id;
                     locationstoadd.add(l);
                 }
             }
             else if(Trigger.isUpdate)
             {
                if(oldrecords.get(c.Id).Create_N_Locations__c<c.Create_N_Locations__c)
                {
                   for(Integer i=0;i<c.Create_N_Locations__c-oldrecords.get(c.Id).Create_N_Locations__c;i++)
                         {
                             Location__c l=new Location__c();
                             l.Name='Commerce'+i;
                             l.Contact__c=c.Id;
                             locationstoadd.add(l);
                         }
                }
                else if(oldrecords.get(c.Id).Create_N_Locations__c>c.Create_N_Locations__c)
                {
                    Integer rectodelete=(Integer)(oldrecords.get(c.Id).Create_N_Locations__c-c.Create_N_Locations__c);
                         for(Location__c loc:locationsupdated.Values())
                         {
                             if(loc.contact__c==c.Id)
                             {
                                 if(locationstodelete.size()<rectodelete)
                                    locationstodelete.add(loc);
                              }
                         }
                }
             }
         }
         if(!locationstoadd.isEmpty())
         {
             insert locationstoadd;
         }
          if(!locationstodelete.isEmpty())
         {
             delete locationstodelete;
         }
         
         
     }
    
    
     public static void ContactTriggerBeforeUpdate(List<Contact> newrecords, Map<Id,Contact> Oldmap) 
     {
          
          List<id> Accids=new List<Id>();
         for(Contact con:newrecords)
         {
             if(Oldmap.get(con.id).Phone!=con.Phone || Oldmap.get(con.id).Email!=con.Email)
             {
                 
                
                   
                    Accids.add(con.AccountId);
                 
             }
         }
        
         if(!Accids.isEmpty())
         {     
             Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>(); 
               for(Id ids:Accids) 
               {
                     List<String> OwneremailIds=new List<String>();
                    List<Account> acc=[SELECT Id,Name,Owner.Email FROM Account WHERE Id IN :Accids];
                    for(Account ac:acc)
                    {
                        OwneremailIds.add(ac.Owner.Email);
                        
                    }
                           Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                                    
                                message.toAddresses = OwneremailIds;
                                message.subject = 'There is a change ';
                                message.plainTextBody = 'Email and Phone got changed';
                                messages.add(message);
                                     
                    
                
               }
                   
             Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
         }
                                
     }
    
    public static void ContactTriggerBeforeInsert(List<Contact> newrecords)
    {
        for(Contact contrec:newrecords)
        {
            if(contrec.LastName==NULL)
            {
             contrec.addError('print lastname');
            }
        }
        
        List<Contact> con=[SELECT Id, LastName, Email, Phone FROM Contact WHERE LastName =:newrecords[0].LastName AND Email=:newrecords[0].Email AND Phone=:newrecords[0].phone];
        if(con.size()>0)
        {
            con[0].addError('This contact is already located');
        }
        
        
        
         List<Id> Acids=new List<Id>();
         for(Contact cons:newrecords)
         {
             Acids.add(cons.AccountId);
         }
        /* Map<Id,Account> accs=new Map<Id,Account>([SELECT Id,BillingCity FROM Account WHERE Id IN :Acids]);
         for(Contact c:newrecords)
         {
               if(accs.containskey(c.AccountId))
                 {
                     c.MailingCity=accs.get(c.AccountId).BillingCity;
                 }
             
         }*/
        List<Account> accs=[SELECT Id,BillingCity FROM Account WHERE Id IN :Acids];
        
         for(Contact c:newrecords)
         {
             for(Account acc:accs)
             {
                 if(acc.Id==c.AccountId)
                 {
                     c.MailingCity=acc.BillingCity;
                 }
             }
         }
        
        List<Id> accids=new List<Id>();
        for(Contact cont:newrecords)
        {
            accids.add(cont.AccountId);    
        }
       
        Map<Id,Account> AccountIdMap=new Map<Id,Account>([SELECT Id,Max_contacts_allowed__c,(SELECT Id FROM Contacts) FROM Account WHERE Id IN:accids]);
        
        for(Id acId:AccountIdMap.keySet())
        {
            
            Integer noofcontacts=(AccountIdMap.get(acId).contacts).size();
            if(noofcontacts >= (AccountIdMap.get(acId).Max_contacts_allowed__c))
            {
                for(Contact contact:newrecords)
                {
                    contact.addError('This contact cant be created');
                }
            }
        }
        
    }

}