/**
 * Contact domain implementation
 */
public class ContactsDomain extends ApplicationSObjectDomain implements IContactsDomain {
    
    public ContactsDomain(List<Contact> records) {
        super(records);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new ContactsDomain(records);
        }
    }
    
    public void sayHello() {
        // Basic domain method that will be extended by injections
        System.debug('Hello from ContactsDomain base implementation!');
        
        // This is where the domain process coordinator will inject additional processes
        this.getDomainProcessCoordinator().processDomainLogicInjections('sayHello');
    }
    
    public override void onAfterInsert() {
        // Standard trigger handler
        System.debug('Contact records were inserted: ' + getRecords().size());
    }
}