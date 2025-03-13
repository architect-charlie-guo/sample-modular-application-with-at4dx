# The AT4DX (Advanced Techniques to Adopt Salesforce DX) Framework

---

## 1. Introduction

**AT4DX** is a framework built on top of the Apex Enterprise Patterns (fflib) to facilitate modular application development in Salesforce, especially with **Salesforce DX Unlocked Packages**. It integrates heavily with **Force-DI** (Dependency Injection) to bind interfaces and concrete implementations at runtime.

Key **goals** of AT4DX:

1. **Modular Unlocked Packages** – Encourage designing Salesforce applications as multiple, independent yet interconnected packages.
2. **Extensibility** – Allow new behavior to be introduced without modifying existing code.
3. **Configuration over Coding** – Leverage **Custom Metadata Types** to configure domain logic, query extensions, platform event subscriptions, etc.
4. **Testability** – Use **Dependency Injection** to enable mocking and isolate testing at every layer (domain, selector, service).

---

## 2. Architectural Overview

AT4DX extends classical Apex Enterprise Patterns (Domain, Selector, Service, Unit of Work) with **additional frameworks**:

1. **Application Factory**: Central factory for creating domain, selector, service, and unit of work instances with dependency injection.
2. **Domain Process Injection**: Dynamically inject criteria and actions into domain methods without modifying the domain class.
3. **Selector Method Injection**: Dynamically add query methods to selectors.
4. **Platform Event Distributor**: Facilitate cross-package/event-driven architectures.
5. **Test Data Supplementation**: Extend test data creation with package-specific logic.

### 2.1 Why a Framework Like AT4DX?

- **Loose Coupling**: By decoupling implementations from interfaces, teams can independently develop new features.
- **Versioning / Unlocked Packages**: Minimizes the need to re-deploy or update the base package for new functionality.
- **Metadata-Driven**: Changing logic or adding new logic can be done via custom metadata records rather than code changes.

---

## 3. Application Factory

### 3.1 Concept

The **Application Factory** is the top-level entry point. It uses the **Force-DI** injector and **custom metadata** bindings to:

- Create domain classes (`Application.Domain.newInstance(...)`)
- Create selector classes (`Application.Selector.newInstance(...)`)
- Create service classes, unit of work instances, etc.

### 3.2 Anatomy of the Factory

A typical `Application` class looks like this:

```apex
public class Application {
    public static final DomainFactory     Domain     = new DomainFactory();
    public static final SelectorFactory   Selector   = new SelectorFactory();
    public static final ServiceFactory    Service    = new ServiceFactory();
    public static final UnitOfWorkFactory UnitOfWork = new UnitOfWorkFactory();
    
    public class DomainFactory {
        public IApplicationSObjectDomain newInstance(List<SObject> records) {
            // Delegates to Force-DI to find the right domain class for the SObject
            return (IApplicationSObjectDomain)di_Injector.Org.getInstance(
                IApplicationSObjectDomain.class, 
                records.getSObjectType()
            );
        }
        // Additional domain-related methods...
    }
    
    public class SelectorFactory {
        public IApplicationSObjectSelector newInstance(SObjectType sObjectType) {
            return (IApplicationSObjectSelector)di_Injector.Org.getInstance(
                IApplicationSObjectSelector.class, 
                sObjectType
            );
        }
        // Additional selector-related methods...
    }
    
    // ... ServiceFactory, UnitOfWorkFactory
}
```

### 3.3 Custom Metadata Bindings

A **custom metadata record** might look like this:

```xml
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Contact Domain</label>
    <protected>false</protected>
    <values>
        <field>BindingSObject__c</field>
        <value xsi:type="xsd:string">Contact</value>
    </values>
    <values>
        <field>To__c</field>
        <value xsi:type="xsd:string">ContactsDomain.Constructor</value>
    </values>
</CustomMetadata>
```

- **`BindingSObject__c`**: The SObject type to bind (e.g., `Contact`).
- **`To__c`**: The class or `fflib_SObjectDomain.IConstructable` reference that should be instantiated.

When the Application Factory calls `di_Injector.Org.getInstance(IApplicationSObjectDomain.class, Contact.SObjectType)`, Force-DI consults these metadata records to map `Contact` → `ContactsDomain.Constructor`.

---

## 4. Domain Process Injection

**Domain Process Injection** is the most **unique** and **powerful** feature in AT4DX. It allows you to **inject additional logic** into a domain method at runtime, based on **custom metadata** configurations.

### 4.1 The Mechanism Behind `this.getDomainProcessCoordinator().processDomainLogicInjections('executeBusinessLogic')`

Consider this typical domain method:

```apex
public void executeBusinessLogic() {
    // Base implementation logic here
    System.debug('Executing base domain logic...');

    // EXTENSION POINT: Injection
    this.getDomainProcessCoordinator().processDomainLogicInjections('executeBusinessLogic');
}
```

When the code calls:

```apex
this.getDomainProcessCoordinator().processDomainLogicInjections('executeBusinessLogic');
```

the following **sequence** of events occurs:

1. **Retrieve the Domain Process Coordinator**  
   - The `getDomainProcessCoordinator()` method (in `ApplicationSObjectDomain`) typically uses the Force-DI injector to instantiate a `DomainProcessCoordinator` (or your chosen class implementing `IDomainProcessCoordinator`).

2. **Look up Custom Metadata for "executeBusinessLogic"**  
   - The `DomainProcessCoordinator` consults the `DomainProcessBinding__mdt` records to find all **active** bindings that match:
     - The **SObject** type handled by the current domain (e.g., `Account`, `Contact`, etc.)
     - The **DomainMethodToken** (in this case, `'executeBusinessLogic'`)
     - The **ProcessContext** (often `DomainMethodExecution` unless it’s a trigger or other context)

3. **Organize the Injections by Sequence / Order**  
   - Each binding has fields like `Sequence__c` and `OrderOfExecution__c`.  
   - Criteria (`Type__c = 'Criteria'`) are processed first; action classes (`Type__c = 'Action'`) are processed after the criteria pass the records along.

4. **Execute Each Criteria Class in Turn**  
   - The `DomainProcessCoordinator` instantiates each `IDomainProcessCriteria` class (via `Type.forName()` reflection), passing in the domain’s record set.
   - Each criteria filters or transforms that record set and returns a subset or the same set.  
   - The filtered set is passed to the next criteria in the chain.

5. **Execute Each Action Class on the Filtered Records**  
   - The `DomainProcessCoordinator` then instantiates each `IDomainProcessAction` class, passing it the list of “qualified” records from the final criteria.  
   - Each action runs whatever logic it wants (e.g., updating fields, sending an email, debugging messages).

6. **Result**  
   - The domain logic is now **extended** with additional checks (criteria) and behaviors (actions), all determined by **metadata** rather than code changes in the domain class.

**In short**, that single line:

```apex
processDomainLogicInjections('executeBusinessLogic');
```

**unlocks** a pipeline of custom behaviors inserted **at runtime** according to the domain’s SObject type, the specified method token, and the active custom metadata settings.

### 4.2 Metadata Configuration for Process Injection

An example `DomainProcessBinding__mdt` record for a **criteria**:

```xml
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Large Account Criteria</label>
    <protected>false</protected>
    <values>
        <field>ClassToInject__c</field>
        <value xsi:type="xsd:string">LargeAccountCriteria</value>
    </values>
    <values>
        <field>DomainMethodToken__c</field>
        <value xsi:type="xsd:string">executeBusinessLogic</value>
    </values>
    <values>
        <field>RelatedDomainBindingSObject__c</field>
        <value xsi:type="xsd:string">Account</value>
    </values>
    <values>
        <field>Type__c</field>
        <value xsi:type="xsd:string">Criteria</value>
    </values>
    <!-- Additional fields like OrderOfExecution__c, ProcessContext__c, IsActive__c, etc. -->
</CustomMetadata>
```

And one for an **action**:

```xml
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Update Rating Action</label>
    <protected>false</protected>
    <values>
        <field>ClassToInject__c</field>
        <value xsi:type="xsd:string">UpdateAccountRatingAction</value>
    </values>
    <values>
        <field>DomainMethodToken__c</field>
        <value xsi:type="xsd:string">executeBusinessLogic</value>
    </values>
    <values>
        <field>RelatedDomainBindingSObject__c</field>
        <value xsi:type="xsd:string">Account</value>
    </values>
    <values>
        <field>Type__c</field>
        <value xsi:type="xsd:string">Action</value>
    </values>
    <!-- Additional fields like OrderOfExecution__c, ProcessContext__c, IsActive__c, etc. -->
</CustomMetadata>
```

### 4.3 Criteria and Action Interfaces

**Criteria** classes implement `IDomainProcessCriteria`:

```apex
public interface IDomainProcessCriteria {
    void setRecordsToEvaluate(List<SObject> records);
    List<SObject> run();
}
```

**Action** classes implement `IDomainProcessAction`:

```apex
public interface IDomainProcessAction {
    void setRecordsToActOn(List<SObject> records);
    void run();
}
```

Each approach ensures that **multiple** criteria or actions can be **chained** together in a predictable sequence.

---

## 5. Selector Method Injection

**Selector Method Injection** allows you to extend query logic in a similar metadata-driven fashion, without touching existing selector classes. For instance, if you have a baseline `ContactsSelector` but want to add a new specialized query, you can create an injectable method and configure it via metadata.

Key interfaces:

- **`ISelectorMethodInjectable`**: Base interface for any injectable query logic.
- **`ISelectorMethodParameterable`**: Interface for passing in dynamic parameters.
- **`ISelectorMethodSetable`**: Allows injection of a `fflib_QueryFactory` and parameters.

Implementation typically involves a base class like `AbstractSelectorMethodInjectable`:

```apex
public abstract class AbstractSelectorMethodInjectable 
    implements ISelectorMethodInjectable, ISelectorMethodSetable {
    
    private fflib_QueryFactory qf;
    private ISelectorMethodParameterable params;
    
    public void setQueryFactory(fflib_QueryFactory qf) {
        this.qf = qf;
    }
    public void setParameters(ISelectorMethodParameterable params) {
        this.params = params;
    }
    
    protected fflib_QueryFactory newQueryFactory() {
        return this.qf;
    }
    protected ISelectorMethodParameterable getParameters() {
        return this.params;
    }
}
```

Through the **custom metadata** records, the selector class can discover these injectables at runtime and add them to the query pipeline.

---

## 6. Platform Event Distributor

The **Platform Event Distributor** sub-framework addresses **cross-package** communication using **platform events**. It uses:

- **`PlatformEventDistributor`**: The core Apex class that routes incoming events.
- **`IEventsConsumer`**: An interface for classes that handle events.
- **`PlatformEvents_Subscription__mdt`**: Metadata that configures which classes handle which event types.

This allows you to **publish** a platform event in one package and **listen** to it in another, all driven by the subscription records in custom metadata.

---

## 7. Test Data Supplementation

**Test Data Supplementation** solves a big problem in multi-package orgs: ensuring tests have consistent data with package-specific fields. It uses:

- **`TestDataSupplementer`**: The main utility class that coordinates “supplementers.”
- **`ITestDataSupplement`**: An interface that supplement classes implement.
- **`TestDataSupplementer__mdt`**: Configures which SObject or scenario a supplement applies to.

When your tests create data, `TestDataSupplementer` is called to ensure any **package-specific** fields or conditions are handled—again, all via metadata.

---

## 8. Design Patterns in AT4DX

1. **Dependency Injection**  
   - AT4DX uses **Force-DI** to decouple implementations from interfaces.  
   - Custom metadata references specify the binding (e.g., `Contact → ContactsDomain`).

2. **Factory Pattern**  
   - The `Application` class provides factories to create domain, selector, and service instances.  
   - This centralizes object creation logic and ensures consistent injection.

3. **Strategy Pattern**  
   - Domain Process Injection is effectively a **Strategy** pattern, where criteria and actions represent distinct strategies for a given domain method.

4. **Observer Pattern**  
   - In the **Platform Event Distributor**, observers (event consumers) register to handle specific events. When an event occurs, the observer’s `run()` method is invoked.

5. **Composite Pattern**  
   - AT4DX can chain multiple criteria or actions, effectively creating a composite pipeline of domain logic.

---

## 9. Common Use Cases

1. **Large Enterprise Applications**  
   Break your org’s functionality into multiple unlocked packages, each with domain logic, selectors, and possibly domain extensions for shared objects.

2. **Independent Teams**  
   Team A owns the “base package” for a given SObject domain. Team B can create an “extension package” with new processes (criteria/actions) that inject at runtime.

3. **Configurable Behaviors**  
   Add or remove domain processes by toggling `IsActive__c` in `DomainProcessBinding__mdt` records—no code deployment required.

4. **Event-Driven Architecture**  
   Use the **Platform Event Distributor** to coordinate cross-package communication, letting teams publish and subscribe to events independently.

5. **Test Data Isolation**  
   Keep package-specific test data logic in test data supplements. This ensures your base test classes remain unaffected by extension packages.

---

## 10. Performance Considerations

1. **Custom Metadata Caching**  
   - AT4DX typically caches custom metadata lookups to avoid repeated queries.
   - Uses static maps or lazy-loading strategies.

2. **Selective Execution**  
   - Domain process injection only executes for relevant domain methods.  
   - Criteria can drastically reduce the number of records that subsequent actions handle.

3. **Asynchronous Options**  
   - Some domain process bindings support an asynchronous approach (`ExecuteAsynchronous__c`) to shift heavy operations to future calls.

4. **Sequence Control**  
   - `OrderOfExecution__c` prevents overhead by letting you define the precise order in which criteria or actions should run.

---

## 11. Detailed Example Flow

A quick hypothetical scenario for an **AccountsDomain**:

1. **AccountsDomain** has a method `calculateAccountRating()`.
2. Inside that method:
   ```apex
   public void calculateAccountRating() {
       System.debug('Base calculation code here...');
       this.getDomainProcessCoordinator().processDomainLogicInjections('calculateAccountRating');
   }
   ```
3. **DomainProcessBinding__mdt** records:
   - A **criteria** record referencing `LargeAccountCriteria`
   - An **action** record referencing `HotRatingAction`
4. At runtime:
   - The **criteria** class filters out only the large accounts.
   - The **action** class sets `Rating = 'Hot'` on those accounts.

All of this is done without modifying the actual `AccountsDomain` code once it’s deployed—new processes can be added by changing or adding more custom metadata.

---

## 12. Testability

AT4DX’s focus on **interfaces** and **dependency injection** means you can **mock** domain or selector classes in your tests:

```apex
@IsTest
private class SomeTest {
    @IsTest
    static void testSomething() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Mock the domain
        IContactsDomain mockDomain = (IContactsDomain)mocks.mock(IContactsDomain.class);
        Application.Domain.setMock(mockDomain);

        // Execute some code that uses IContactsDomain
        // Then verify calls:
        ((IContactsDomain)mocks.verify(mockDomain, 1)).someMethod();
    }
}
```

You can also **test** domain process injection logic by verifying that criteria/actions were triggered under the right conditions, or by using specialized test classes that check the final state of records after injection runs.

---

## 13. Conclusion

**AT4DX** represents an advanced, well-architected approach to building **Salesforce** applications in a **modular** and **extensible** way. By leveraging **Force-DI**, **Custom Metadata** configurations, and carefully layered design patterns (Factory, Strategy, Observer, etc.):

- **You avoid modifying base code** every time new functionality is needed.
- **Teams can collaborate** across multiple unlocked packages without stepping on each other’s toes.
- **Complex business logic** can be managed more flexibly, with new logic added simply by creating new criteria/action classes and metadata records.
- **Testing** is straightforward thanks to the heavy use of interfaces and injection.

The line 
```apex
this.getDomainProcessCoordinator().processDomainLogicInjections('executeBusinessLogic');
``` 
is the **linchpin** for injecting domain-specific logic at runtime. It orchestrates a sequence of **criteria** and **actions**—all discovered via **custom metadata**—and applies them to your records. This architectural design is what makes **AT4DX** so powerful for **enterprise-scale** or **rapidly evolving** Salesforce applications.

**In short:** With AT4DX, you gain a **highly configurable, package-friendly, and testable** environment that goes far beyond the standard Apex Enterprise Patterns, enabling robust **multi-package** solutions in the Salesforce ecosystem.

---

### Additional Resources

- **[AT4DX GitHub Repository](https://github.com/apex-enterprise-patterns/at4dx)**
- **[AT4DX Wiki](https://github.com/apex-enterprise-patterns/at4dx/wiki)**
- **[Apex Enterprise Patterns](https://github.com/apex-enterprise-patterns)**

Use AT4DX to **enhance** how you build, organize, and evolve your Salesforce applications, and you’ll find that **adding new features** or **revising existing logic** becomes a far more **lightweight** and **scalable** process.
