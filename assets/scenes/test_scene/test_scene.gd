extends Node2D

var utils: CombinatoricsUtilities = CombinatoricsUtilities.new()

func _ready() -> void:
	utils.test_combinatorics()
	utils.test_combinatorics_counts()
