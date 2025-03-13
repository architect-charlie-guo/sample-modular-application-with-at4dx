# AT4DX Architecture Overview

This document provides an overview of the AT4DX (Advanced Techniques To Adopt SalesforceDX) framework architecture and how it's used in our Hello World application.

## Framework Components

AT4DX extends the Apex Enterprise Patterns (fflib) and integrates with Force-DI for dependency injection to create a modular, extensible application architecture.

### 1. Application Factory

The Application Factory provides factory methods for creating domain, selector, service, and unit of work instances with dependency injection:

```apex
// Get a domain instance for contact records
IContactsDomain contactsDomain = (IContactsDomain)Application.Domain.newInstance(contacts);

// Get a selector instance for the Contact object
IContactsSelector contactsSelector = (IContactsSelector)Application.Selector.newInstance(Contact.SObjectType);
```

### 2. Domain Process Injection

Domain Process Injection enables extending domain logic without modifying existing code:

```apex
// In the domain class
public void sayHello() {
    System.debug('Hello from base implementation!');
    
    // This is where injected processes are executed
    this.getDomainProcessCoordinator().processDomainLogicInjections('sayHello');
}
```

### 3. Custom Metadata Bindings

Custom metadata records configure the bindings between interfaces and implementations:

- `ApplicationFactory_DomainBinding__mdt` - Binds SObjects to domain classes
- `ApplicationFactory_SelectorBinding__mdt` - Binds SObjects to selector classes
- `DomainProcessBinding__mdt` - Configures process injections for domains

## Hello World Application Flow

The sequence diagram below represents the flow of execution in our Hello World application:

1. The controller retrieves or creates Contact records
2. It uses Application.Domain to get a domain instance
3. When sayHello() is called, the base implementation executes
4. The DomainProcessCoordinator finds process bindings for "sayHello"
5. The criteria class filters contacts with email addresses
6. The action class outputs personalized greetings for the filtered contacts
7. The controller uses a selector to query contacts by last name

## Architecture Benefits

### Modularity

The AT4DX framework enables building applications as modular unlocked packages. Each package can define its own implementations and extensions without modifying base code.

### Separation of Concerns

The framework clearly separates different aspects of the application:
- Domains handle business logic and validation
- Selectors handle data retrieval
- Processes handle specific logic that can be injected into domains

### Testability

The design makes unit testing easier by allowing mock implementations:

```apex
// Mock the domain binding
fflib_ApexMocks mocks = new fflib_ApexMocks();
IContactsDomain mockDomain = (IContactsDomain)mocks.mock(IContactsDomain.class);
Application.Domain.setMock(mockDomain);
```

### Configuration Over Coding

The framework uses custom metadata types for configuration, which means many changes can be made without modifying code:

- Changing bindings between interfaces and implementations
- Adding new process injections
- Enabling/disabling specific processes

## Design Patterns Used

1. **Factory Pattern**: Used in Application.Domain, Application.Selector, etc., to create instances with proper dependency injection.

2. **Dependency Injection**: Used throughout the framework to decouple components and allow for easier testing.

3. **Strategy Pattern**: Implemented in Domain Process Injection to allow different strategies (criteria and actions) to be used.

4. **Observer Pattern**: Used in the platform event distributor component (not shown in Hello World) for event-based communication.

5. **Composite Pattern**: Used to combine multiple processes and criteria in a modular way.

## Extending the Application

To extend the Hello World application without modifying existing code:

1. Create new criteria or action classes
2. Configure new domain process bindings in custom metadata
3. The existing domain methods will automatically use the new processes

This approach allows for true modular development, where different teams or packages can extend functionality without conflicts.
