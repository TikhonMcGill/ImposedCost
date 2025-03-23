class_name ManageNetworkMove
extends PlayCardMove

##Move representing the Manage Network Aspect of the card

var stack_from: int ##The Stack from which to move the Action Card, 0 to 3 representing A to D
var position_from: int ##The Index from which to get the Action Card

var stack_to: int ##The Stack to which to move the Action Card, 0 to 3 representing A to D - it becomes topmost card
