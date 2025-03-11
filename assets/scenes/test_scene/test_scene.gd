extends Node2D

var utils: CombinatoricsUtilities = CombinatoricsUtilities.new()

func _ready() -> void:
	utils.test_subarray_combinatorics()
