# AT4DX Architecture Diagrams

## Component Architecture

The following diagram shows the main components of the AT4DX framework and how they interact:

```mermaid
flowchart TB
    subgraph Application["Application Factory"]
        direction LR
        ApplicationClass["Application Class"]
        Domain["Domain Factory"]
        Selector["Selector Factory"]
        Service["Service Factory"]
        UOW["Unit of Work Factory"]
        
        ApplicationClass --> Domain
        ApplicationClass --> Selector
        ApplicationClass --> Service
        ApplicationClass --> UOW
    end
    
    subgraph DI["Force-DI Framework"]
        Bindings["di_Bindings"]
        Injector["di_Injector"]
        
        Bindings --> Injector
    end
    
    subgraph DomainLayer["Domain Layer"]
        direction LR
        IDomainInterface["IContactsDomain Interface"]
        DomainClass["ContactsDomain Class"]
        
        IDomainInterface -.-> DomainClass
    end
    
    subgraph SelectorLayer["Selector Layer"]
        direction LR
        ISelectorInterface["IContactsSelector Interface"]
        SelectorClass["ContactsSelector Class"]
        
        ISelectorInterface -.-> SelectorClass
    end
    
    subgraph DomainProcessInjection["Domain Process Injection"]
        ProcessCoordinator["DomainProcessCoordinator"]
        Criteria["ContactsWithEmailCriteria"]
        Action["ContactGreetingAction"]
        
        ProcessCoordinator --> Criteria
        ProcessCoordinator --> Action
    end
    
    subgraph CustomMetadata["Custom Metadata"]
        DomainBindings["ApplicationFactory_DomainBinding__mdt"]
        SelectorBindings["ApplicationFactory_SelectorBinding__mdt"]
        ProcessBindings["DomainProcessBinding__mdt"]
    end
    
    subgraph Controller["Hello World Controller"]
        ControllerClass["HelloWorldController"]
    end
    
    %% Connections between components
    DI <--> Application
    DI <--> DomainProcessInjection
    
    CustomMetadata --> DI
    
    Domain --> DomainLayer
    Selector --> SelectorLayer
    
    DomainClass --> ProcessCoordinator
    
    ControllerClass --> Application
```

## Execution Flow

The sequence diagram below shows the flow of execution in our Hello World application:

```mermaid
sequenceDiagram
    participant Client
    participant Controller as HelloWorldController
    participant Application as Application Factory
    participant Domain as ContactsDomain
    participant DPC as DomainProcessCoordinator
    participant Criteria as ContactsWithEmailCriteria
    participant Action as ContactGreetingAction
    participant Selector as ContactsSelector
    
    Client->>Controller: processContacts()
    
    rect rgb(240, 240, 255)
    Note over Controller,Application: Domain Instantiation
    Controller->>Controller: Query/Create Contacts
    Controller->>Application: Domain.newInstance(contacts)
    Application-->>Controller: contactsDomain (IContactsDomain)
    end
    
    rect rgb(240, 255, 240)
    Note over Controller,Action: Domain Process Injection Flow
    Controller->>Domain: sayHello()
    Domain->>Domain: System.debug("Hello from base impl!")
    Domain->>DPC: processDomainLogicInjections("sayHello")
    
    DPC->>DPC: Find process bindings for "sayHello"
    DPC->>Criteria: setRecordsToEvaluate(contacts)
    DPC->>Criteria: run()
    Criteria-->>DPC: filteredContacts (with email)
    
    DPC->>Action: setRecordsToActOn(filteredContacts)
    DPC->>Action: run()
    Action->>Action: Debug greetings for each contact
    end
    
    rect rgb(255, 240, 240)
    Note over Controller,Selector: Selector Usage
    Controller->>Application: Selector.newInstance(Contact.SObjectType)
    Application-->>Controller: contactsSelector (IContactsSelector)
    Controller->>Selector: selectByLastName("Smith")
    Selector-->>Controller: smithContacts
    Controller->>Controller: System.debug results
    end
    
    Client-->>Controller: Done
```

## Package Modularity

The following diagram illustrates how AT4DX enables modular package development:

```mermaid
flowchart TB
    subgraph BasePackage["Base Package"]
        BaseClasses["Base Framework Classes"]
        BaseInterfaces["Domain & Selector Interfaces"]
        CoreImplementation["Core Implementations"]
    end
    
    subgraph ExtensionPackage1["Extension Package 1"]
        ExtensionCriteria1["Custom Criteria Classes"]
        ExtensionActions1["Custom Action Classes"]
        CustomMDT1["Custom Metadata Bindings"]
    end
    
    subgraph ExtensionPackage2["Extension Package 2"]
        ExtensionCriteria2["Custom Criteria Classes"]
        ExtensionActions2["Custom Action Classes"]
        CustomMDT2["Custom Metadata Bindings"]
    end
    
    BaseInterfaces --> ExtensionPackage1
    BaseInterfaces --> ExtensionPackage2
    
    ExtensionPackage1 --"Extends without modification"--> BasePackage
    ExtensionPackage2 --"Extends without modification"--> BasePackage
```
