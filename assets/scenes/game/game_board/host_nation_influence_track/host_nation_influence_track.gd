class_name HostNationInfluenceTrack
extends HBoxContainer

##A Graphical Representation of the Host Nation Influence Track in Imposed Cost

@export var influence_pointer: ColorRect ##The Influence Pointer

@export var influence_slots: Array[PanelContainer] ##The Individual Slots for PanelContainers, which should contain a VBoxContainer as well

##Set the Host Nation Influence Position
func set_hn_influence(pos: int) -> void:
	pos = clampi(pos, -4, 4)
	
	var new_index: int = 4 + pos
	influence_pointer.get_parent().remove_child(influence_pointer)
	influence_slots[new_index].get_node("VBoxContainer").add_child(influence_pointer)
