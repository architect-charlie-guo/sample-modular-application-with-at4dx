/**
 * Interface for the Contact selector
 */
public interface IContactsSelector extends IApplicationSObjectSelector {
    List<Contact> selectById(Set<Id> recordIds);
    List<Contact> selectByLastName(String lastName);
}