/**
 * * This test class test the MaintenanceRequestHelper class.
 */
@istest
public with sharing class MaintenanceRequestHelperTest {
  /**
   * Create a test record for:
   * Vehicle, Maintenance Request, Equipment maintenance item, and Equipment
   * create the vehicles and equipment records first, then the maintenance requests, then the equipment maintenance items so that they all can be properly associated
   */
  private static Vehicle__c createVehicle() {
    Vehicle__c vehicle = new Vehicle__c(name = 'Tesla');
    return vehicle;
  }

  private static Product2 createEq() {
    Product2 equipment = new Product2(
      name = 'Tesla Battery',
      Lifespan_Months__c = 120,
      Maintenance_Cycle__c = 12,
      Replacement_Part__c = true
    );

    return equipment;
  }

  private static Case createMaintReq(Id vehicleId) {
    Case maintReq = new Case(
      Type = 'Repair',
      Status = 'New',
      Origin = 'Web',
      Subject = 'Test Subject',
      Vehicle__c = vehicleId
    );

    return maintReq;
  }

  private static Equipment_Maintenance_Item__c createEquipMaintItem(
    Id equipmentId,
    Id maintReqId
  ) {
    Equipment_Maintenance_Item__c equipMaintItem = new Equipment_Maintenance_Item__c(
      Equipment__c = equipmentId,
      Maintenance_Request__c = maintReqId
    );

    return equipMaintItem;
  }
  @istest
  private static void positiveMaintReqTest() {
    Vehicle__c testVehicle = createVehicle();
    Product2 testEq = createEq();

    insert testVehicle;
    insert testEq;

    Id vehicleId = testVehicle.Id;
    Id eqId = testEq.Id;

    Case testMaintReq = createMaintReq(vehicleId);
    insert testMaintReq;
    Id maintReqId = testMaintReq.Id;

    Equipment_Maintenance_Item__c testEqMaintItem = createEquipMaintItem(
      eqId,
      maintReqId
    );
    insert testEqMaintItem;

    /**
     * Change test Maintenance Request record status to close
     */
    test.startTest();
    testMaintReq.status = 'Closed';
    update testMaintReq;
    test.stopTest();

    /**
     * Create variables to store new maintenance request and related equipment maintenance item
     */
    Case newMaintReq = [
      SELECT Id, Subject, Type, Vehicle__c, Date_Reported__c
      FROM Case
      WHERE Status = 'New'
    ];

    Equipment_Maintenance_Item__c newEqMaintItem = [
      SELECT id
      FROM Equipment_Maintenance_Item__c
      WHERE Maintenance_Request__c = :newMaintReq.Id
    ];
    /**
     * Assert that the maintenance request and equipment maintenance item was created and done correctly
     */
    system.assert(newMaintReq.Subject != null);
    system.assertEquals('Routine Maintenance', newMaintReq.Type);
    system.assertEquals(vehicleId, newMaintReq.Vehicle__c);
    system.assert(newEqMaintItem != null);
    system.assertEquals(Date.today(), newMaintReq.Date_Reported__c);
  }
  @istest
  private static void negativeMaintReqTest() {
    /**
     * Create a test record for:
     * Vehicle, Maintenance Request, Equipment maintenance item, and Equipment
     * create the vehicles and equipment records first, then the maintenance requests, then the equipment maintenance items so that they all can be properly associated
     */
    Vehicle__c testVehicle = createVehicle();
    Product2 testEq = createEq();

    insert testVehicle;
    insert testEq;

    Id vehicleId = testVehicle.Id;
    Id eqId = testEq.Id;

    Case testMaintReq = createMaintReq(vehicleId);
    insert testMaintReq;
    Id maintReqId = testMaintReq.Id;

    Equipment_Maintenance_Item__c testEqMaintItem = createEquipMaintItem(
      eqId,
      maintReqId
    );
    insert testEqMaintItem;
    /**
     * Change test Maintenance Request record status to working
     */
    test.startTest();
    testMaintReq.Status = 'Working';
    update testMaintReq;
    test.stopTest();
    /**
     * Create variables to store all maintenance requests
     */
    List<Case> allMaintReqs = [SELECT id FROM Case];
    /**
     * Assert that the there is only one Maintenance request, as none should have been created
     */
    system.assert(allMaintReqs.size() == 1);
  }
  @istest
  private static void bulkMaintReqTest() {
    /**
     * Create multiple records of the following:
     * Vehicle, Maintenance Request, Equipment maintenance item, and Equipment
     * create the vehicles and equipment records first, then the maintenance requests, then the equipment maintenance items so that they all can be properly associated
     */
    List<Vehicle__c> testVehicles = new List<Vehicle__c>();
    List<Product2> testEq = new List<Product2>();

    for (Integer i = 0; i < 300; i++) {
      testVehicles.add(createVehicle());
      testEq.add(createEq());
    }
    insert testVehicles;
    insert testEq;

    List<Case> testMaintReqs = new List<Case>();
    for (Integer i = 0; i < 300; i++) {
      testMaintReqs.add(createMaintReq(testVehicles.get(i).Id));
    }
    insert testMaintReqs;

    List<Equipment_Maintenance_Item__c> testEqMaintItems = new List<Equipment_Maintenance_Item__c>();
    for (Integer i = 0; i < 300; i++) {
      testEqMaintItems.add(
        createEquipMaintItem(testEq.get(i).Id, testMaintReqs.get(i).Id)
      );
    }
    insert testEqMaintItems;
    /**
     * Change maintenance request status to close for all maintenance requests
     */
    test.startTest();
    for (Case maintReq : testMaintReqs) {
      maintReq.Status = 'Closed';
    }
    update testMaintReqs;
    test.stopTest();
    /**
     * Create a variable to hold all new maintenance requests
     */
    List<Case> newMaintReqs = [SELECT id FROM Case WHERE Status = 'New'];
    /**
     * Assert that there are 300 new maintenance records as 300 should have been created.
     */
    system.assert(newMaintReqs.size() == 300);
  }
}