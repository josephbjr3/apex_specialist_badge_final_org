/**
 * * When an existing maintenance request of type Repair or Routine Maintenance is closed, create a new maintenance request for a future routine checkup. This new maintenance request is tied to the same Vehicle and Equipment Records as the original closed request. For record keeping purposes the existing equipment maintenance items must remain tied to the original close request so new records must be created. This new request's Type should be set as Routine Maintenance. The Subject should not be null and the Report Date field reflects the day the request was created. Remember, all equipment has maintenance cycles.

* * Calculate the maintenance request due dates by using the maintenance cycle defined on the related equipment records. If multiple pieces of equipment are used in the maintenance request, define the due date by applying the shortest maintenance cycle to today’s date.

* * Design the code to work for both single and bulk maintenance requests. Bulkify the system to successfully process approximately 300 records of offline maintenance requests that are scheduled to import together. For now, don’t worry about changes that occur on the equipment record itself.

* * Also expose the logic for other uses in the org. Separate the trigger (named MaintenanceRequest) from the application logic in the handler (named MaintenanceRequestHelper). This setup makes it simpler to delegate actions and extend the app in the future.
* Maintenance Request (Case was renamed) | Maintenance_Request__c
* Equipment (Product was renamed) | Equipment__c
 */

/**
 * "Separate the trigger (named MaintenanceRequest) from the application logic in the handler (named MaintenanceRequestHelper)"
 * //TODO: create trigger handler named MaintenanceRequestHelper
 * //TODO: Check for an update to the status field from a non-closed value to closed.
 *  To do this we need the list of records before and after the update. To make matching the "before    and after" records easier, we will use a list for updated cases and map for "beforeUpdate" cases. Pass those lists as arguments recieved from the trigger.
 * //TODO: check the type of the updated records (must Repair or Routine Maintenance)
 *  to do this we can use an if statement and just check the type. we can combine this and the previous TODO into one if statement.
 *  //TODO: create a set to capture Id's of maintenance request that are updated to close status and are type 'Repair' or 'Mainenance'.
 * TODO:: create a new maintenance request for each closed request.
 *  to create a new request we need the following fields:
 *      "beforeUpdate" record id (to copy over indirectly related record (equipment). Since an equipment maintenance item record can only have one related maintenance request, and considering that the equipment record is directly related to the equipment maintenance item record but indirectly related to the maintenance request record, we will have to clone the relevant the equipment maintenance items and pull the related equipment records.,
 *      Vehicle. Since the vehicle object can be associated with multiple maintenance requests we can just assign it directly.,
 *          //TODO: get "beforeUpdate" record id:
 *      type (set to Routine Maintenance),
 *      subject (set to anything except null),
 *      report date (set to created date),
 *          //TODO: figure out the syntax to get created date
 *      due date (set to the created date plus the shortest maintenance cycle of all the related equipment)
 *          //TODO: figure out syntax to get created date and shortest maintenance cycle once you find it
 *              //TODO: for shortest maintenance cycle you will want get an array of aggregated results which will have the shortest maintenance cycle (of all the related equipment) for reach maintenance request
 *      status (required)
 *      origin (required)
 * //TODO: create equipment maintenance item related records for each new maintenance request record
 *  to do this we will need to clone the equipment items records in the orginal records.
 *  we can use the corresponding "beforeUpdate" record id to pull the list of equipment maintenance items to iterate through and clone
 *  we can iterate through the updated Cases and pull the updated Case id to attach it the to the cloned equipment item records.
 *  you can use a nest for loop to accomplish this efficiently with the outer loop for the updated maintenance requests and the inner loop for the list of equipment maintenance items of each "beforeUpdate" maintenance requests
 *  have a list to capture all the new equipment maintenance item records
 *  insert the records
 */

public with sharing class MaintenanceRequestHelper {
  public static void onAfterUpdate(
    List<Case> updatedCases,
    Map<Id, Case> originalCases
  ) {
    // create set to hold relevant case Ids. relevant meaning the cases we're going to work with
    Set<Id> relevantcaseIds = new Set<Id>();

    // write logic to add relevant case Ids to the relevantcaseId set
    for (Case c : updatedCases) {
      if (
        (c.Type == 'Repair' || c.Type == 'Routine Maintenance') &&
        (originalCases.get(c.id).Status != 'Closed' &&
        c.Status == 'Closed')
      ) {
        relevantcaseIds.add(c.Id);
      }
    }

    // make sure you actually have some relevant cases to work with
    if (!relevantcaseIds.isEmpty()) {
      // create agg. result array that holds every equipment maintenance item record that has the related equipment record with the shortest maintenance cycle for each maintenance request that meets our criteria (aka in 'validIds' set). these records will help us set the due date for reach maintenance request due date (particulary the maintenance cycle for each record)
      // note: an AggregateResult is a special sObject type used to store the results of aggregate queries (queries using aggregate functions like COUNT, SUM, AVG, etc.)
      // note: can access related record "Equipment__r" even though is not defined as a field for
      // the  "Equipment_Maintenance_Item__c" object. Just need "Equipment__c" defined on the
      // "Equipment_Maintenance_Item__c" object.
      // note: to use MIN() you need GROUP BY to define boundaries (ie MIN() in each GROUP BY)

      // Get the shortest maintenance cycle for each updated case
      AggregateResult[] shortestMaintCycles = [
        SELECT
          Maintenance_Request__c,
          MIN(Equipment__r.Maintenance_Cycle__c) maintCycle // maintCycle = name of the MIN() result
        FROM Equipment_Maintenance_Item__c
        WHERE Maintenance_Request__c IN :relevantcaseIds
        GROUP BY Maintenance_Request__c
      ];
      // create map of maintenance cycles and the related case id and fill it

      Map<Id, Decimal> maintenanceCycles = new Map<Id, Decimal>();
      for (AggregateResult ar : shortestMaintCycles) {
        maintenanceCycles.put(
          (Id) ar.get('Maintenance_Request__c'),
          (Decimal) ar.get('maintCycle')
        );
      }

      // get the vehicle, id, and related equipment maintenance item records of the revelant updated cases
      // use map instead of list so that you can use the .get(<Id>) method later
      // note: the contstructor auto-maps the case id to the key, no need to write code for it.
      Map<Id, Case> relevantUpdatedCases = new Map<Id, Case>(
        [
          SELECT
            Id,
            Vehicle__c,
            Equipment__r.maintenance_Cycle__c,
            (SELECT Id FROM Equipment_Maintenance_Items__r)
          FROM Case
          WHERE Id IN :relevantcaseIds
        ]
      );

      // list to hold new cases that will be created that correlate with relevant updated cases
      List<Case> newCases = new List<Case>();

      // create new cases
      for (Case c : relevantUpdatedCases.values()) {
        Case nc = new Case(
          Vehicle__c = c.Vehicle__c,
          ParentId = c.Id,
          Subject = 'Routine Maintenance',
          Type = 'Routine Maintenance',
          Date_Reported__c = Date.today(),
          Origin = 'Web',
          Status = 'New'
        );

        if (maintenanceCycles.containskey(c.Id)) {
          nc.Date_Due__c = Date.today()
            .addDays((Integer) maintenanceCycles.get(c.id));
        } /*else {
          nc.Date_Due__c = Date.today();
            //.addDays((Integer) c.Equipment__r.maintenance_Cycle__c);
        }
        */
        // set the due date for each new case. use if statement match up the new case with updated case
        // for (AggregateResult ar : shortestMaintCycles) {
        //   if (c.Id == (Id) ar.get('Maintenance_Request__c')) {
        //     nc.Date_Due__c = Date.today()
        //       .addDays((Integer) ar.get('maintCycle'));
        //   }
        // }
        newCases.add(nc);
      }
      insert newCases;

      // create list to capture the new equipment maintenance related records for each new case
      List<Equipment_Maintenance_Item__c> newEMIs = new List<Equipment_Maintenance_Item__c>();

      // clone the equipment maintenance related records for each relevant updated case
      // relate the cloned record to the new case
      // add the cloned record the newEMIs list to be later inserted
      for (Case c : newCases) {
        for (
          Equipment_Maintenance_Item__c emi : relevantUpdatedCases.get(
              c.ParentId
            )
            .Equipment_Maintenance_Items__r
        ) {
          Equipment_Maintenance_Item__c emiClone = emi.clone();
          emiClone.Maintenance_Request__c = c.Id;
          newEMIs.add(emiClone);
        }
      }
      insert newEMIs;
    }
  }
}

