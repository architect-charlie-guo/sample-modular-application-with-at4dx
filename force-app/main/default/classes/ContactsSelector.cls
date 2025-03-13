/**
 * Contact selector implementation
 */
public class ContactsSelector extends ApplicationSObjectSelector implements IContactsSelector {
    
    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Contact.Id,
            Contact.FirstName,
            Contact.LastName,
            Contact.Email,
            Contact.Phone
        };
    }
    
    public List<Contact> selectById(Set<Id> recordIds) {
        return (List<Contact>) selectSObjectsById(recordIds);
    }
    
    public List<Contact> selectByLastName(String lastName) {
        fflib_QueryFactory qf = newQueryFactory();
        qf.setCondition('LastName = :lastName');
        return (List<Contact>) Database.query(qf.toSOQL());
    }
}