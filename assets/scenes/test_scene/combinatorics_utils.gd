class_name CombinatoricsUtils
extends Resource

## Generates all unique combinations of k elements from an array
## Parameters:
## - arr: Array to generate combinations from
## - k: Number of elements in each combination
## - with_replacement: Whether to allow repeated elements
## - order_matters: Whether order matters (permutations vs combinations)
## Returns: Array of combinations, where each combination is an array
func generate_combinations(arr: Array, k: int, with_replacement: bool = false, order_matters: bool = false) -> Array:
	var results: Array = []
	
	# Validate input
	if k <= 0 or arr.size() == 0:
		return results
	if not with_replacement and k > arr.size():
		return results
	
	# Generate initial combinations
	if with_replacement:
		_combinations_with_replacement(arr, [], 0, k, results)
	else:
		_combinations_without_replacement(arr, [], 0, k, results)
	
	# If order matters, generate permutations for each combination
	if order_matters:
		var permutations: Array = []
		for combo in results:
			permutations.append_array(_generate_permutations(combo))
		
		# Remove duplicates if we had any repeated elements
		if with_replacement:
			var unique_perms = {}
			for perm in permutations:
				var perm_str = str(perm)
				unique_perms[perm_str] = perm
			permutations = unique_perms.values()
		
		results = permutations
	
	return results

## Helper method for generating combinations without replacement
func _combinations_without_replacement(arr: Array, current: Array, start: int, remaining: int, results: Array) -> void:
	if remaining == 0:
		results.append(current.duplicate())
		return
		
	for i in range(start, arr.size()):
		current.append(arr[i])
		_combinations_without_replacement(arr, current, i + 1, remaining - 1, results)
		current.pop_back()

## Helper method for generating combinations with replacement
func _combinations_with_replacement(arr: Array, current: Array, start: int, remaining: int, results: Array) -> void:
	if remaining == 0:
		results.append(current.duplicate())
		return
		
	for i in range(start, arr.size()):
		current.append(arr[i])
		_combinations_with_replacement(arr, current, i, remaining - 1, results)
		current.pop_back()

## Helper method for generating permutations
func _generate_permutations(combination: Array) -> Array:
	if combination.size() <= 1:
		return [combination]
	
	var perms: Array = []
	var first = combination[0]
	var rest = combination.slice(1)
	
	for sub_perm in _generate_permutations(rest):
		for i in range(sub_perm.size() + 1):
			var new_perm = sub_perm.duplicate()
			new_perm.insert(i, first)
			perms.append(new_perm)
	
	return perms

## Helper function to calculate factorial
func _factorial(x: int) -> int:
	if x <= 1:
		return 1
	return x * _factorial(x - 1)

## Calculates the number of possible combinations/permutations without generating them
## Parameters:
## - n: Size of the array
## - k: Number of elements to choose
## - with_replacement: Whether to allow repeated elements
## - order_matters: Whether order matters (permutations vs combinations)
## Returns: Integer representing the number of possible combinations/permutations
func count_combinations(n: int, k: int, with_replacement: bool = false, order_matters: bool = false) -> int:
	# Handle invalid inputs
	if k <= 0 or n <= 0:
		return 0
	if not with_replacement and k > n:
		return 0
	
	# Calculate based on the type of combination needed
	var result: int = 0
	
	if with_replacement:
		if order_matters:
			# Permutation with replacement: n^k
			result = pow(n, k)
		else:
			# Combination with replacement: (n+k-1)! / (k! * (n-1)!)
			result = _factorial(n + k - 1) / (_factorial(k) * _factorial(n - 1))
	else:
		if order_matters:
			# Permutation without replacement: n! / (n-k)!
			result = _factorial(n) / _factorial(n - k)
		else:
			# Combination without replacement: n! / (k! * (n-k)!)
			result = _factorial(n) / (_factorial(k) * _factorial(n - k))
	
	return result



# Example usage:
func _ready() -> void:
	var test_array = [1, 2, 3]
	var k = 2
	
	# Get all combinations of 2 elements without replacement, order doesn't matter
	var combinations = generate_combinations(test_array, k, false, false)
	print("Combinations without replacement:", combinations)
	# Output: [[1, 2], [1, 3], [2, 3]]
	
	# Get all combinations of 2 elements with replacement, order doesn't matter
	combinations = generate_combinations(test_array, k, true, false)
	print("Combinations with replacement:", combinations)
	# Output: [[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]]
	
	# Get all permutations of 2 elements without replacement (order matters)
	combinations = generate_combinations(test_array, k, false, true)
	print("Permutations without replacement:", combinations)
	# Output: [[1, 2], [2, 1], [1, 3], [3, 1], [2, 3], [3, 2]]
	
	# Get all permutations of 2 elements with replacement (order matters)
	combinations = generate_combinations(test_array, k, true, true)
	print("Permutations with replacement:", combinations)
	# Output: [[1, 1], [1, 2], [2, 1], [1, 3], [3, 1], [2, 2], [2, 3], [3, 2], [3, 3]]
	
	# Additional test cases:
	print("")
	
	# Test Case 1: Single-element combinations (k=1)
	var single_elements = generate_combinations(test_array, 1, false, false)
	print("Single-element combinations:", single_elements)
	# Output: [[1], [2], [3]]
	
	# Test Case 2: All possible combinations (k=3)
	var all_elements = generate_combinations(test_array, 3, false, false)
	print("All elements combination:", all_elements)
	# Output: [[1, 2, 3]]
	
	# Test Case 3: String array with k=2
	var string_array = ["A", "B", "C", "D"]
	var string_combinations = generate_combinations(string_array, 2, false, true)
	print("String permutations:", string_combinations)
	# Output: [[A, B], [B, A], [A, C], [C, A], [A, D], [D, A], [B, C], [C, B], [B, D], [D, B], [C, D], [D, C]]
	
	# Test Case 4: Empty array (should return empty result)
	var empty_array = []
	var empty_result = generate_combinations(empty_array, 2, false, false)
	print("Empty array result:", empty_result)
	# Output: []
	
	# Test Case 5: k > array size with replacement
	var larger_k = generate_combinations(test_array, 4, true, false)
	print("k>n with replacement:", larger_k)
	# Output: [[1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 1, 3], ...]
	
	print("\nTesting count_combinations function:")
	
	var n = 3  # Size of array [1, 2, 3]
	var j = 2  # Choose 2 elements
	
	# Count combinations without replacement (order doesn't matter)
	var count = count_combinations(n, j, false, false)
	print("Number of combinations without replacement (n=3, k=2):", count)
	# Output: 3 ([1,2], [1,3], [2,3])
	
	# Count combinations with replacement (order doesn't matter)
	count = count_combinations(n, j, true, false)
	print("Number of combinations with replacement (n=3, k=2):", count)
	# Output: 6 ([1,1], [1,2], [1,3], [2,2], [2,3], [3,3])
	
	# Count permutations without replacement (order matters)
	count = count_combinations(n, j, false, true)
	print("Number of permutations without replacement (n=3, k=2):", count)
	# Output: 6 ([1,2], [2,1], [1,3], [3,1], [2,3], [3,2])
	
	# Count permutations with replacement (order matters)
	count = count_combinations(n, j, true, true)
	print("Number of permutations with replacement (n=3, k=2):", count)
	# Output: 9 ([1,1], [1,2], [2,1], [1,3], [3,1], [2,2], [2,3], [3,2], [3,3])
	
	# Test some edge cases
	print("Count when k > n without replacement (n=3, k=4):", count_combinations(3, 4, false, false))
	# Output: 0 (impossible)
	
	print("Count when k > n with replacement (n=3, k=4):", count_combinations(3, 4, true, false))
	# Output: 15 (possible with replacement)
	
	print("Count for single elements (n=3, k=1):", count_combinations(3, 1, false, false))
	# Output: 3 ([1], [2], [3])
