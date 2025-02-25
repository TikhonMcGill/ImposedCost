class_name CombinatoricsUtilities
extends Resource

##Generates all unique combinations of k elements from an array, with or witohut replacement,
##and with optional order
func generate_combinations(array: Array, k: int, with_replacement: bool, order_matters: bool) -> Array:
	#Validate input
	if k <= 0 or array.is_empty() == true:
		return []
	
	if with_replacement == false and k > array.size():
		return []
	
	var results: Array = []
	
	#Generate initial combinations
	if with_replacement == true:
		_combinations_with_replacement(array, [], 0, k, results)
	else:
		_combinations_without_replacement(array, [], 0, k, results)
	
	#If order matters, generate permutations for each combination
	if order_matters == true:
		var permutations: Array = []
		for combination: Array in results:
			permutations.append_array(_generate_permutations(combination))
		
		#Remove duplicates if we had any repeated elements
		if with_replacement == true:
			var unique_permutations: Dictionary = {}
			for permutation: Array in permutations:
				var perm_str: String = str(permutation)
				unique_permutations[perm_str] = permutation
			permutations = unique_permutations.values()
		
		results = permutations
	
	return results

##Helper method for generating combinations without replacement
func _combinations_without_replacement(array: Array, current: Array, start: int, remaining: int, results: Array) -> void:
	if remaining == 0:
		results.append(current.duplicate())
		return
	
	for i: int in range(start, array.size()):
		current.append(array[i])
		_combinations_without_replacement(array, current, i + 1, remaining - 1, results)
		current.pop_back()

##Helper method for generating combinations with replacement
func _combinations_with_replacement(array: Array, current: Array, start: int, remaining: int, results: Array) -> void:
	if remaining == 0:
		results.append(current.duplicate())
		return
	
	for i: int in range(start, array.size()):
		current.append(array[i])
		_combinations_with_replacement(array, current, i, remaining - 1, results)
		current.pop_back()

##Helper method for generating permutations
func _generate_permutations(combination: Array) -> Array:
	if combination.size() <= 1:
		return [combination]
	
	var permutations: Array = []
	var first: Variant = combination[0]
	var rest: Array = combination.slice(1)
	
	for sub_permutation: Array in _generate_permutations(rest):
		for i in range(sub_permutation.size() + 1):
			var new_perm: Array = sub_permutation.duplicate()
			new_perm.insert(i, first)
			permutations.append(new_perm)
	
	return permutations

##Function to calculate factorial
func factorial(x: int) -> int:
	if x <= 1:
		return 1
	return x * factorial(x - 1)

##Calculates the number of possible combinations/permutations without generating them, with or without replacement,
##and with possible order
func count_combinations(n: int, k: int, with_replacement: bool = false, order_matters: bool = false) -> int:
	#Handle invalid inputs
	if k <= 0 or n <= 0:
		return 0
	if with_replacement == false and k > n:
		return 0
	
	#Calculate based on the type of combination needed
	if with_replacement == true:
		if order_matters == true:
			#Permutation with replacement: n ^ k
			return pow(n, k)
		else:
			#Combination with replacement: (n+k-1)! / (k! * (n-1)!)
			return factorial(n + k - 1) / (factorial(k) * factorial(n - 1))
	else:
		if order_matters == true:
			#Permutation without replacement: n! / (n-k)!
			return factorial(n) / factorial(n - k)
		else:
			#Combination without replacement: n! / (k! * (n-k)!)
			return factorial(n) / (factorial(k) * factorial(n - k))

##Test Cases for generating combinations or permutations
func test_combinatorics() -> void:
	var test_array: Array = [1, 2, 3]
	var k: int = 2
	
	#Get all combinations of 2 elements without replacement, order doesn't matter
	var combinations: Array = generate_combinations(test_array, k, false, false)
	assert(combinations == [[1, 2], [1, 3], [2, 3]])
	
	#Get all combinations of 2 elements with replacement, order doesn't matter
	combinations = generate_combinations(test_array, k, true, false)
	assert(combinations == [[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]])
	
	#Get all combinations of 2 elements with replacement and with order mattering
	combinations = generate_combinations(test_array, k, true, true)
	assert(combinations == [
		[1, 1], [1, 2], [2, 1],
		[1, 3], [3, 1], [2, 2],
		[2, 3], [3, 2], [3, 3]
	])
	
	#Get all permutations of 2 elements without replacement (order matters)
	combinations = generate_combinations(test_array, k, false, true)
	assert(combinations == [[1, 2], [2, 1], [1, 3], [3, 1], [2, 3], [3, 2]])
	
	#Get all permutations of 2 elements with replacement (order matters)
	combinations = generate_combinations(test_array, k, true, true)
	assert(combinations == [[1, 1], [1, 2], [2, 1], [1, 3], [3, 1], [2, 2], [2, 3], [3, 2], [3, 3]])
	
	#Test Case 1: Single-element combinations (k=1)
	var single_elements: Array = generate_combinations(test_array, 1, false, false)
	assert(single_elements == [[1], [2], [3]])
	
	#Test Case 2: All possible combinations (k=3)
	var all_elements: Array = generate_combinations(test_array, 3, false, false)
	assert(all_elements == [[1, 2, 3]])
	
	#Test Case 3: String array with k=2
	var string_array: Array = ["A", "B", "C", "D"]
	var string_combinations: Array = generate_combinations(string_array, 2, false, true)
	assert(string_combinations == [["A", "B"], ["B", "A"], ["A", "C"], ["C", "A"], ["A", "D"], ["D", "A"], ["B", "C"], ["C", "B"], ["B", "D"], ["D", "B"], ["C", "D"], ["D", "C"]])
	
	#Test Case 4: Empty array (should return empty result)
	var empty_array: Array = []
	var empty_result: Array = generate_combinations(empty_array, 2, false, false)
	assert(empty_result.is_empty() == true)
	
	#Test Case 5: k > array size with replacement
	var larger_k: Array = generate_combinations(test_array, 4, true, false)
	assert(larger_k == [[1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 1, 3], [1, 1, 2, 2], [1, 1, 2, 3], [1, 1, 3, 3], [1, 2, 2, 2], [1, 2, 2, 3], [1, 2, 3, 3], [1, 3, 3, 3], [2, 2, 2, 2], [2, 2, 2, 3], [2, 2, 3, 3], [2, 3, 3, 3], [3, 3, 3, 3]])

##Test Cases for counting combinations/permutations
func test_combinatorics_counts() -> void:
	var n: int = 3  #Size of array [1, 2, 3]
	var j: int = 2  #Choose 2 elements
	
	#Count combinations without replacement (order doesn't matter)
	var count: int = count_combinations(n, j, false, false)
	assert(count == 3)
	
	#Count combinations with replacement (order doesn't matter)
	count = count_combinations(n, j, true, false)
	assert(count == 6)
	
	#Count permutations without replacement (order matters)
	count = count_combinations(n, j, false, true)
	assert(count == 6)
	
	#Count permutations with replacement (order matters)
	count = count_combinations(n, j, true, true)
	assert(count == 9)
	
	#Test some edge cases
	count = count_combinations(3, 4, false, false)
	assert(count == 0)
	
	count = count_combinations(3, 4, true, false)
	assert(count == 15)
	
	count = count_combinations(3, 1, false, false)
	assert(count == 3)
