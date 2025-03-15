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

##Helper method for Constructing Possible Array Partitions (helper function for getting
##combinations of subarrays)
func _get_possible_partitions(base_array_size: int, subarray_count: int, all_elements: bool, allow_empty: bool) -> Array:
	var possible_partitions: Array = []
	
	var possible_partition_numbers: Array = []
	
	#If empty subarrays are allowed, add 0 as a possible subarray size
	if allow_empty == true:
		possible_partition_numbers.append(0)
	
	#Append all possible sizes of subarrays to partition numbers
	for x in range(1, base_array_size + 1):
		possible_partition_numbers.append(x)
	
	var partition_combinations: Array = generate_combinations(possible_partition_numbers, subarray_count, true, true)
	for p: Array in partition_combinations:
		var total_element_size: int = 0
		for elem: int in p:
			total_element_size += elem
		
		if total_element_size == base_array_size:
			possible_partitions.append(p)
		elif total_element_size < base_array_size and all_elements == false:
			possible_partitions.append(p)
	
	return possible_partitions

##Apply a Partition to an Array, converting it into Subarrays of sizes determined by Partitions
func _apply_partition(subarray_elements: Array, partitions: Array) -> Array:
	var result: Array = []
	var duplicated_elements: Array = subarray_elements.duplicate()
	
	for p: int in partitions:
		var subarray: Array = duplicated_elements.slice(0, p)
		duplicated_elements = duplicated_elements.slice(p)
		result.append(subarray)
	
	return result

##Check if two Subarrays are Equal
func _are_subarrays_equal(first_subarray: Array, second_subarray: Array, order_matters: bool) -> bool:
	#If the two subarrays are of different sizes, they're obviously different
	if len(first_subarray) != len(second_subarray):
		return false
	
	#If order matters, compare elements one-by-one at exact positions
	if order_matters == true:
		for i in range(len(first_subarray)):
			if first_subarray[i] != second_subarray[i]:
				return false
		return true
	
	#If order doesn't matter, simply make sure every element in the first subarray is
	#also in the second
	for e: Variant in first_subarray:
		if e not in second_subarray:
			return false
	
	return true

##Check if two Subarray Combinations are Equal
func _are_subarray_combinations_equal(first_combination: Array, second_combination: Array, order_matters: bool, internal_order_matters: bool) -> bool:
	#If the Combinations are of different length, they're obviously not equal
	if len(first_combination) != len(second_combination):
		return false
	
	#If order matters, check if each subarray in first combination is equal in second combination IN THAT POSITION
	if order_matters == true:
		for i in range(len(first_combination)):
			#Whether order matters in subarray comparisons is based on whether internal order matters
			if _are_subarrays_equal(first_combination[i], second_combination[i], internal_order_matters) == false:
				return false
		
		return true
	
	#Otherwise, just check if, for each subarray in the first combination, there is an equal one in the second combination
	var equal_counts: int = 0 #The no. Equal Subarrays Found
	
	for subarray: Array in first_combination:
		for second_subarray: Array in second_combination:
			if _are_subarrays_equal(subarray, second_subarray, internal_order_matters) == true:
				equal_counts += 1
	
	return equal_counts == len(first_combination)

##Check if a Subarray Combination is Valid
func _is_combination_valid(combination: Array, base_array: Array, all_elements: bool) -> bool:
	if all_elements == false:
		return true
	
	#Calculate the sum of the lengths of the subarrays
	var sum_of_lens: int = 0
	for subarray: Array in combination:
		sum_of_lens += len(subarray)
	
	#If the sum of lengths is less than the length of the base array, we're definitely missing something
	if sum_of_lens < len(base_array):
		return false
	
	#Iterate through the base array, making sure its elements are in one of the subarrays
	for elem: Variant in base_array:
		var is_present: bool = false
		
		for subarray: Array in combination:
			if elem in subarray:
				is_present = true
				break
		
		if is_present == false:
			return false
	
	return true

##TODO Generate all possible combinations of sub_array_count Subarrays, given an Array array
##For example, given sub_array_count of 3, generate all possible combinations of 3 Subarrays
##If allow_empty == True, then empty Subarrays are allowed
##If all_elements == True, then EVERY element in the Array must appear at least once in the Subarrays
##If with_replacement == True, then there can be multiple instances of the same Element in the Subarrays
##If order_matters == True, then there can be subarrays with the exact same elements, BUT with different ordering amongst them
##If internal_order_matters == True, then elements inside the subarrays themselves can be of different orders
func generate_subarray_combinations(base_array: Array, subarray_count: int, allow_empty: bool, all_elements: bool, with_replacement: bool, order_matters: bool, internal_order_matters: bool) -> Array:
	#If given an empty array, and allow_empty is false, return []
	if base_array.is_empty() == true and allow_empty == false:
		return []
	
	#If given an empty array, and allow_empty is true, simply return array with subarray_count empty arrays
	if base_array.is_empty() == true and allow_empty == true:
		var result: Array = []
		
		for x in range(subarray_count):
			result.append([])
		
		return [result]
	
	var possible_subarray_combinations: Array = []
	
	#Get all possible orders of elements and all possible partitions
	var element_combinations: Array = generate_combinations(base_array, len(base_array), false, internal_order_matters)
	var partition_combinations: Array = _get_possible_partitions(len(base_array), subarray_count, all_elements, allow_empty)
	
	#Get all possible combinations
	var all_combinations: Array = []
	for p: Array in partition_combinations:
		for e: Array in element_combinations:
			all_combinations.append(_apply_partition(e, p))
	
	print("Filtering Applied Partitions...")
	#Iterate through all partitions
	for combination: Array in all_combinations:
		print(combination)
		
		var valid: bool = _is_combination_valid(combination, base_array, all_elements)
		
		if valid == false:
			break
		
		for p: Array in possible_subarray_combinations:
			if _are_subarray_combinations_equal(combination, p, order_matters, internal_order_matters) == true:
				valid = false
				break
		
		if valid == true:
			possible_subarray_combinations.append(combination)
	
	return possible_subarray_combinations

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

##Test Cases for Subarray Combinatorics
func test_subarray_combinatorics() -> void:
	#Test the _get_possible_partitions helper func
	
	#Array Size 3, 2 Subarrays
	assert(_get_possible_partitions(3, 2, true, true) == [[0, 3], [3, 0], [1, 2], [2, 1]])
	assert(_get_possible_partitions(3, 2, true, false) == [[1, 2], [2, 1]])
	assert(_get_possible_partitions(3, 2, false, true) == [[0, 0], [0, 1], [1, 0], [0, 2], [2, 0], [0, 3], [3, 0], [1, 1], [1, 2], [2, 1]])
	assert(_get_possible_partitions(3, 2, false, false) == [[1, 1], [1, 2], [2, 1]])
	
	#Array Size 4, 2 Subarrays
	assert(_get_possible_partitions(4, 2, true, true) == [[0, 4], [4, 0], [1, 3], [3, 1], [2, 2]])
	assert(_get_possible_partitions(4, 2, true, false) == [[1, 3], [3, 1], [2, 2]])
	assert(_get_possible_partitions(4, 2, false, true) == [[0, 0], [0, 1], [1, 0], [0, 2], [2, 0], [0, 3], [3, 0], [0, 4], [4, 0], [1, 1], [1, 2], [2, 1], [1, 3], [3, 1], [2, 2]])
	assert(_get_possible_partitions(4, 2, false, false) == [[1, 1], [1, 2], [2, 1], [1, 3], [3, 1], [2, 2]])
	
	#Array Size 4, 3 Subarrays
	assert(_get_possible_partitions(4, 3, true, true) == [[0, 0, 4], [0, 4, 0], [4, 0, 0], [0, 1, 3], [1, 0, 3], [1, 3, 0], [0, 3, 1], [3, 0, 1], [3, 1, 0], [0, 2, 2], [2, 0, 2], [2, 2, 0], [1, 1, 2], [1, 2, 1], [2, 1, 1]])
	assert(_get_possible_partitions(4, 3, true, false) == [[1, 1, 2], [1, 2, 1], [2, 1, 1]])
	assert(_get_possible_partitions(4, 3, false, true) == [[0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0], [0, 0, 2], [0, 2, 0], [2, 0, 0], [0, 0, 3], [0, 3, 0], [3, 0, 0], [0, 0, 4], [0, 4, 0], [4, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 0], [0, 1, 2], [1, 0, 2], [1, 2, 0], [0, 2, 1], [2, 0, 1], [2, 1, 0], [0, 1, 3], [1, 0, 3], [1, 3, 0], [0, 3, 1], [3, 0, 1], [3, 1, 0], [0, 2, 2], [2, 0, 2], [2, 2, 0], [1, 1, 1], [1, 1, 2], [1, 2, 1], [2, 1, 1]])
	assert(_get_possible_partitions(4, 3, false, false) == [[1, 1, 1], [1, 1, 2], [1, 2, 1], [2, 1, 1]])
	
	#Test the _apply_partition helper func
	assert(_apply_partition([1, 2, 3], [0, 0, 0]) == [[], [], []])
	assert(_apply_partition([1, 2, 3], [1, 1, 1]) == [[1], [2], [3]])
	assert(_apply_partition([1, 2, 3], [1, 2, 0]) == [[1], [2, 3], []])
	assert(_apply_partition([1, 2, 3], [2, 1, 0]) == [[1, 2], [3], []])
	assert(_apply_partition([1, 2, 3], [2, 0, 1]) == [[1, 2], [], [3]])
	
	#Test the _are_subarrays_equal helper func
	assert(_are_subarrays_equal([1, 2], [1], false) == false)
	assert(_are_subarrays_equal([1, 2], [1, 2, 3], true) == false)
	
	assert(_are_subarrays_equal([1, 2], [1, 2], true) == true)
	assert(_are_subarrays_equal([1, 2], [1, 2], false) == true)
	assert(_are_subarrays_equal([1, 2], [2, 1], true) == false)
	assert(_are_subarrays_equal([1, 2], [2, 1], false) == true)
	
	assert(_are_subarrays_equal([1, 2, 3], [1, 2, 3], true) == true)
	assert(_are_subarrays_equal([1, 2, 3], [3, 2, 1], true) == false)
	assert(_are_subarrays_equal([1, 2, 3], [3, 2, 1], false) == true)
	
	#Test the _are_subarray_combinations_equal helper func
	var test_array: Array = [[1, 2], [3, 4]]
	
	assert(_are_subarray_combinations_equal([[1, 2], [1]], [[1, 2]], true, true) == false)
	
	assert(_are_subarray_combinations_equal(test_array, test_array, true, true) == true)
	assert(_are_subarray_combinations_equal(test_array, [[2, 1], [4, 3]], true, false) == true)
	assert(_are_subarray_combinations_equal(test_array, [[3, 4], [1, 2]], false, true) == true)
	assert(_are_subarray_combinations_equal(test_array, [[4, 3], [2, 1]], false, false) == true)
	
	assert(_are_subarray_combinations_equal(test_array, [[3, 4], [1, 2]], true, true) == false)
	assert(_are_subarray_combinations_equal(test_array, [[4, 3], [2, 1]], true, false) == false)
	assert(_are_subarray_combinations_equal(test_array, [[4, 3], [2, 1]], false, true) == false)
	assert(_are_subarray_combinations_equal(test_array, [[3, 3], [4, 4]], false, false) == false)
	
	#Test the _is_combination_valid helper func
	var test_base_array: Array = [1, 2]
	
	assert(_is_combination_valid([[1], [2]], test_base_array, true) == true)
	assert(_is_combination_valid([[1, 2]], test_base_array, true) == true)
	assert(_is_combination_valid([[1]], test_base_array, true) == false)
	assert(_is_combination_valid([[1]], test_base_array, false) == true)
	
	#Finally, test the final array
	#Empty Array, n = 2
	#var test_empty_array: Array = []
	#assert(generate_subarray_combinations(test_empty_array, 2, true, false, true, true, true) == [[[], []]])
	#assert(generate_subarray_combinations(test_empty_array, 2, false, false, true, true, true) == [])
	#
	print(generate_subarray_combinations([1, 2, 3, 4, 5, 6], 4, true, true, false, true, true))
