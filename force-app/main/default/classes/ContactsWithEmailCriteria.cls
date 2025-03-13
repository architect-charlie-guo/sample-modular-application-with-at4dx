/**
 * A criteria class that filters contacts with emails
 */
public class ContactsWithEmailCriteria implements IDomainProcessCriteria {
    private List<SObject> recordsToEvaluate;
    
    public void setRecordsToEvaluate(List<SObject> records) {
        this.recordsToEvaluate = records;
    }
    
    public List<SObject> run() {
        List<SObject> results = new List<SObject>();
        
        for(SObject record : recordsToEvaluate) {
            Contact con = (Contact)record;
            if(String.isNotBlank(con.Email)) {
                results.add(record);
            }
        }
        
        return results;
    }
}