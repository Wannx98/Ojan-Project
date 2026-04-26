extends Node

var cave_cache = {}

#cache buat nyimpen seed
func get_cave(seed: int):
	if cave_cache.has(seed):
		return cave_cache[seed]

	var cave = generate_cave(seed)
	cave_cache[seed] = cave

	return cave

#func generate
func generate_cave(seed: int):
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var grid = []

	for y in range(50):
		var row = []
		for x in range(50):
			row.append(rng.randf() > 0.55)
		grid.append(row)

	return grid
