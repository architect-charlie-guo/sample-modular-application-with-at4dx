/**
 * Test class for Hello World application
 */
@IsTest
private class HelloWorldTest {
    
    @IsTest
    static void testHelloWorld() {
        // Create test data
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName='Test', LastName='User', Email='test.user@example.com')
        };
        insert contacts;
        
        // Mock the domain binding
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContactsDomain mockDomain = (IContactsDomain)mocks.mock(IContactsDomain.class);
        Application.Domain.setMock(mockDomain);
        
        // Mock the selector binding
        IContactsSelector mockSelector = (IContactsSelector)mocks.mock(IContactsSelector.class);
        mocks.startStubbing();
        mocks.when(mockSelector.selectByLastName('User')).thenReturn(contacts);
        mocks.stopStubbing();
        Application.Selector.setMock(mockSelector);
        
        // Set test start point
        Test.startTest();
        
        // Execute the controller method
        HelloWorldController.processContacts();
        
        // Verify domain method was called
        ((IContactsDomain)mocks.verify(mockDomain, 1)).sayHello();
        
        Test.stopTest();
    }
}