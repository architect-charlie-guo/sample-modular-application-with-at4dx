/**
 * A simple controller to demonstrate using the AT4DX components
 */
public with sharing class HelloWorldController {
    
    public static void processContacts() {
        // Create or find some contacts to process
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 5];
        
        if(contacts.isEmpty()) {
            // Create some test contacts if none exist
            contacts = new List<Contact>{
                new Contact(FirstName='John', LastName='Doe', Email='john.doe@example.com'),
                new Contact(FirstName='Jane', LastName='Smith', Email='jane.smith@example.com'),
                new Contact(FirstName='Bob', LastName='Johnson', Email=null)
            };
            insert contacts;
            
            // Refresh the contacts to get their IDs
            contacts = [SELECT Id, FirstName, LastName, Email FROM Contact 
                        WHERE LastName IN ('Doe', 'Smith', 'Johnson')];
        }
        
        // Use Application factory to get domain instance
        IContactsDomain contactsDomain = (IContactsDomain)Application.Domain.newInstance(contacts);
        
        // Call the domain method which will trigger process injections
        contactsDomain.sayHello();
        
        // Use a selector to query contacts
        IContactsSelector contactsSelector = (IContactsSelector)Application.Selector.newInstance(Contact.SObjectType);
        List<Contact> smithContacts = contactsSelector.selectByLastName('Smith');
        
        System.debug('Found ' + smithContacts.size() + ' contacts with last name Smith');
    }
}