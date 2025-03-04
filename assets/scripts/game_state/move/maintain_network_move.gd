class_name MaintainNetworkMove
extends Move

##A Move representing a specific removal of 1 or 2 Action Cards, and the reorganization of a Network
##
##This becomes relevant when the "Maintain Network" Card is Drawn, whose effects execute immediately.

var cards_to_discard: Array[Card] ##Cards to Discard from the Player's Hand

var new_network_order: Array[ActionCard] ##The new order of Action Cards in the Player's Network
