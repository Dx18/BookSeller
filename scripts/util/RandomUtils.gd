# Utility functions for random

# Returns random element from given array
static func choose_one(array: Array, random: RandomNumberGenerator):
	return array[random.randi_range(0, len(array) - 1)]

# Returns `count` randomly chosen elements from given array with different
# indices. Relative order of elements is preserved
static func choose_unique_ordered(
	array: Array, count: int, random: RandomNumberGenerator
) -> Array:
	assert(
		count <= len(array),
		"Cannot choose %d elements from %d" % [count, len(array)]
	)
	
	# Choosing indices
	var indices = []
	for i in range(count):
		indices.append(random.randi_range(0, len(array) - count))
	
	# Making them unique
	indices.sort()
	for i in range(count):
		indices[i] += i
	
	# Making result array
	var result = []
	for i in range(count):
		result.append(array[indices[i]])
	
	return result

# Returns `count` randomly chosen elements from given array with different
# indices
static func choose_unique_unordered(
	array: Array, count: int, random: RandomNumberGenerator
) -> Array:
	var result = choose_unique_ordered(array, count, random)
	result.shuffle()
	return result
