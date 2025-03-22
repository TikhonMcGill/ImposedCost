class_name BuildNetworkMove
extends PlayCardMove

##Move Representing playing the "Build Network" part of the Build/Manage/Degrade Network Card

var action_cards_to_add: Array[ActionCard] ##Action Cards to add to the network
var stacks_to_add_to: Array[int] ##Int indices (0 = A, 1 = B, etc.) of Stacks to whom these Cards will be added
var indices_to_add_to: Array[int] ##Positions (as indices) to insert Action Cards into in the relevant stacks
