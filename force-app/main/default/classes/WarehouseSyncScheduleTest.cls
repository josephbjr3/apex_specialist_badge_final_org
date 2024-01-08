/**
 * * This schedule class is used to schedule a job that invokes the WarehouseCalloutService class.
 */
@IsTest
public with sharing class WarehouseSyncScheduleTest {
  @isTest
  static void WarehouseSyncScheduleTest() {
    //TODO create schedule time string
    String scheduleTime = '00 00 01 * * ?';
    //TODO set up mock callout and create schedule job, save the id in a string
    test.startTest();
    test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
    String schJobId = system.schedule(
      'Inventory update',
      scheduleTime,
      new WarehouseSyncSchedule()
    );
    test.stopTest();

    //TODO query new created schedule jo and save it in a variable
    CronTrigger a = [SELECT Id FROM CronTrigger WHERE NextFireTime > today];

    //TODO assert that the id is correct
    System.assertEquals(schJobId, a.Id);
  }
}
