/**
 * * This class simply invokes the WarehouceCalloutService class when assigned to a scheduled Apex task
 */
global with sharing class WarehouseSyncSchedule implements Schedulable {
  global void execute(SchedulableContext context) {
    WarehouseCalloutService.updateInventory();
  }
}
