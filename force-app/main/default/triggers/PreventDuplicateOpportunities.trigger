/**
 * * This trigger prevents duplicate opportunities from being inserted by comparing their descriptions (which should have unique urls)
 */
trigger PreventDuplicateOpportunities on Opportunity(before insert) {
  OpportunityTriggerHandler.onBeforeInsert(Trigger.new);
}