/**
 * * This class pulls the Warehouse inventory of equipment and updates the Salesforce inventory equipment.
 */
public with sharing class WarehouseCalloutService {
  // TODO: create constant for the callout url
  public static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

  @future(callout=true)
  public static void updateInventory() {
    //TODO: create list of equipment to upsert later
    List<Product2> latestEquip = new List<Product2>();

    //TODO: create and send HTTP request
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(WAREHOUSE_URL);
    req.setMethod('GET');
    HttpResponse res = http.send(req);

    //TODO: convert HTTP response from json string to list of objects
    if (res.getStatusCode() == 200) {
      System.debug(res.getBody());
      List<Object> jsonPayload = (List<Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      //TODO: iterate through list of objects, converting each object into a map of string, object. Then create a new equipment record and assign it the updated field values. add the new equipment record to the list of equipment to be upserted later
      for (Object o : jsonPayload) {
        Map<String, Object> mapOfObj = (Map<String, Object>) o;
        Product2 eqToUpsert = new Product2();
        eqToUpsert.Cost__c = (Integer) mapOfObj.get('cost');
        eqToUpsert.Current_Inventory__c = (Integer) mapOfObj.get('quantity');
        eqToUpsert.Lifespan_Months__c = (Integer) mapOfObj.get('lifespan');
        eqToUpsert.Maintenance_Cycle__c = (Integer) mapOfObj.get(
          'maintenanceperiod'
        );
        eqToUpsert.Name = (String) mapOfObj.get('name');
        eqToUpsert.Replacement_Part__c = (Boolean) mapOfObj.get('replacement');
        eqToUpsert.Warehouse_SKU__c = (String) mapOfObj.get('sku');
        latestEquip.add(eqToUpsert);
      }
      //TODO upsert list of equipment
      if (latestEquip.size() > 0) {
        upsert latestEquip;
        System.debug('Warehouse equipment sync successful');
      }
    }
  }

  //TODO write execute method so that the warehouse method executes when an instance of this class is enqueued
  // public static void execute(QueueableContext context) {
  //   updateInventory();
  // }
}

