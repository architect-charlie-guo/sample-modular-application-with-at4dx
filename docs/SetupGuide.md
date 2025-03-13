# AT4DX Hello World Application - Setup Guide

This guide will walk you through setting up the AT4DX Hello World application in a Salesforce org that already has the AT4DX framework installed.

## Prerequisites

1. A Salesforce DX org with the AT4DX framework installed
2. Salesforce CLI installed on your computer
3. Visual Studio Code with Salesforce Extension Pack (recommended)

## Project Structure

This Hello World application has the following structure:

```
force-app/
└── main/
    ├── default/
    │   ├── classes/
    │   │   ├── IContactsDomain.cls
    │   │   ├── ContactsDomain.cls
    │   │   ├── IContactsSelector.cls
    │   │   ├── ContactsSelector.cls
    │   │   ├── ContactsWithEmailCriteria.cls
    │   │   ├── ContactGreetingAction.cls
    │   │   ├── HelloWorldController.cls
    │   │   └── HelloWorldTest.cls
    │   └── customMetadata/
    │       ├── ApplicationFactory_DomainBinding__mdt.Contact_Domain.md-meta.xml
    │       ├── ApplicationFactory_SelectorBinding__mdt.Contact_Selector.md-meta.xml
    │       ├── DomainProcessBinding__mdt.Contact_EmailCriteria.md-meta.xml
    │       └── DomainProcessBinding__mdt.Contact_GreetingAction.md-meta.xml
```

## Deployment Steps

### Using Salesforce CLI

1. Navigate to the project root directory
2. Deploy the code to your org using:
   ```
   sfdx force:source:deploy -p force-app
   ```

### Using Visual Studio Code

1. Open the project in Visual Studio Code
2. Use the Command Palette (Ctrl+Shift+P or Cmd+Shift+P)
3. Select "SFDX: Deploy Source to Org"
4. Choose the "force-app" folder when prompted

## Running the Application

1. Open the Developer Console in your Salesforce org
2. Click Debug > Open Execute Anonymous Window
3. Enter the following code and click Execute:
   ```apex
   HelloWorldController.processContacts();
   ```
4. Check the debug logs to see the output:
   - You should see "Hello from ContactsDomain base implementation!"
   - For contacts with emails, you should see "Hello, [FirstName] [LastName]! Welcome to AT4DX."

## Understanding the Code

### Domain Layer

- `IContactsDomain` - Interface that defines the domain behavior for Contacts
- `ContactsDomain` - Implementation of the Contact domain with a `sayHello()` method

### Selector Layer

- `IContactsSelector` - Interface that defines query methods for Contacts
- `ContactsSelector` - Implementation of the Contact selector with methods to query by ID and last name

### Domain Process Injection

- `ContactsWithEmailCriteria` - Criteria class that filters contacts with emails
- `ContactGreetingAction` - Action class that outputs personalized greetings for contacts

### Controller

- `HelloWorldController` - Demonstrates using the AT4DX components to process contacts

### Custom Metadata

- `ApplicationFactory_DomainBinding__mdt.Contact_Domain` - Binds the Contact SObject to our domain class
- `ApplicationFactory_SelectorBinding__mdt.Contact_Selector` - Binds the Contact SObject to our selector class
- `DomainProcessBinding__mdt.Contact_EmailCriteria` - Binds our criteria class to the sayHello() method
- `DomainProcessBinding__mdt.Contact_GreetingAction` - Binds our action class to the sayHello() method

## Testing

1. Run the test class to verify that the application works as expected:
   ```
   sfdx force:apex:test:run -n HelloWorldTest -r human
   ```

2. The test class demonstrates how to mock domain and selector classes for unit testing.

## Next Steps

1. Explore the AT4DX framework in more depth
2. Try extending the Hello World application with additional functionality
3. Create your own domain, selector, and process injection classes

## Additional Resources

- [AT4DX GitHub Repository](https://github.com/apex-enterprise-patterns/at4dx)
- [AT4DX Wiki](https://github.com/apex-enterprise-patterns/at4dx/wiki)
- [Apex Enterprise Patterns](https://github.com/apex-enterprise-patterns)