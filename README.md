# AT4DX Hello World Application

This is a simple "Hello World" application that demonstrates the core concepts of the AT4DX (Advanced Techniques To Adopt SalesforceDX) framework. 

## Overview

AT4DX is a framework built on top of the Apex Enterprise Patterns (fflib) that facilitates the adoption of Salesforce DX Unlocked Packages using modular design patterns. It extends the traditional patterns with dependency injection and modular extension capabilities.

This Hello World application demonstrates:

1. **Domain Layer**: A Contact domain with a sayHello() method
2. **Selector Layer**: A Contact selector with query methods
3. **Domain Process Injection**: A criteria class to filter contacts and an action class to perform operations on them
4. **Application Factory**: Factory methods for creating domain and selector instances
5. **Custom Metadata Bindings**: Configuration that connects everything together

## Project Structure

```
force-app/
└── main/
    ├── default/
    │   ├── classes/              # Apex classes
    │   └── customMetadata/       # Custom metadata records
    └── docs/                     # Documentation
        ├── SetupGuide.md         # Instructions for deployment
        ├── ArchitectureOverview.md # Framework architecture explanation
        └── ArchitectureDiagram.md # Visual representation of the architecture
```

## Getting Started

See [SetupGuide.md](docs/SetupGuide.md) for detailed instructions on how to deploy and run this application.

## Key Concepts Demonstrated

1. **Dependency Injection**: Using Force-DI to bind implementations to interfaces
2. **Domain Process Injection**: Extending domain behavior without modifying base classes
3. **Application Factory**: Using factory methods to create instances with proper dependency injection
4. **Separation of Concerns**: Clearly separating domain logic, selectors, and processes
5. **Configuration Over Coding**: Using custom metadata to configure behavior

## Learn More

- [AT4DX GitHub Repository](https://github.com/apex-enterprise-patterns/at4dx)
- [AT4DX Wiki](https://github.com/apex-enterprise-patterns/at4dx/wiki)
- [Apex Enterprise Patterns](https://github.com/apex-enterprise-patterns)

## Architecture

For a detailed overview of the architecture, see [ArchitectureOverview.md](docs/ArchitectureOverview.md) and [ArchitectureDiagram.md](docs/ArchitectureDiagram.md).
