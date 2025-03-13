/**
 * An action class that outputs a greeting for contacts
 */
public class ContactGreetingAction implements IDomainProcessAction {
    private List<SObject> recordsToActOn;
    
    public void setRecordsToActOn(List<SObject> records) {
        this.recordsToActOn = records;
    }
    
    public void run() {
        for(SObject record : recordsToActOn) {
            Contact con = (Contact)record;
            System.debug('Hello, ' + con.FirstName + ' ' + con.LastName + '! Welcome to AT4DX.');
        }
    }
}