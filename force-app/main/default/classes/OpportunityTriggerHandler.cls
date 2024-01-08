/**
 * * This is class is the trigger handler for the PreventDuplicateOpportunities trigger. It prevents duplicate opportunities from being inserted by comparing their descriptions (which should have unique urls)
 */
public with sharing class OpportunityTriggerHandler {
  public static void onBeforeInsert(List<Opportunity> newOpportunities) {
    Set<String> allDescriptions = getAllDescriptions();

    List<Opportunity> duplicates = new List<Opportunity>();

    for (Opportunity opp : newOpportunities) {
      if (allDescriptions.contains(opp.Description)) {
        duplicates.add(opp);
      }
    }

    if (!duplicates.isEmpty()) {
      for (Opportunity dup : duplicates) {
        dup.Description.addError('Duplicate(s) error');
      }
    }
  }

  private static Set<String> getAllDescriptions() {
    Set<String> allDescriptions = new Set<String>();
    for (Opportunity opp : [SELECT Description FROM Opportunity]) {
      allDescriptions.add(opp.Description);
    }
    return allDescriptions;
  }
}