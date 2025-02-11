public class CaseTriggerHelperclass {
    
    public static void CaseTriggerHelper(List<Case> cases){
        List<user> userlist=[SELECT Id, Profile.Name, Name FROM user WHERE Profile.Name=:'System Administrator'];
        for(Case Cas:cases)
        {
           If(UserInfo.getUserId()!=userlist[0].Id)
              {
                   Cas.addError('Case cant be deleted');
              }
           
        }
        
    }

}