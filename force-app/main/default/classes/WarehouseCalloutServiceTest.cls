/**
 * * This test class tests the WarehouseCalloutService class. To uses the mock callout class 'WarehouseCalloutServiceMock' to create a generate fake http response.
 */
@IsTest
private class WarehouseCalloutServiceTest {
  // implement your mock callout test here
  //TODO create test class
  @IsTest
  static void testWarehouseCalloutService() {
    //TODO setup mock callout,  invoke callout service
    test.startTest();
    test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
    WarehouseCalloutService.updateInventory();
    test.stopTest();

    //TODO assert there is one product created
    system.assertEquals(1, [SELECT COUNT() FROM Product2]);
  }
}
