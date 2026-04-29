extends Node

var cave_cache = {}

#cache buat nyimpen seed
func get_cave(seed: int):
	if cave_cache.has(seed):
		return cave_cache[seed]

	var cave = generate_cave(seed)
	cave_cache[seed] = cave

	return cave

#func menghitung tile tetangga 
func count_neighbors(grid, x, y):
	var count = 0
	
	for ny in range(y - 1, y + 2):
		for nx in range(x - 1, x + 2):
			
			if nx == x and ny == y:
				continue
			
			if nx < 0 or ny < 0 or nx >= grid[0].size() or ny >= grid.size():
				count += 1 # anggap luar map = wall
			elif grid[ny][nx]:
				count += 1
	
	return count
	
#perhalus noise dari hasil hitung tetangga 
func smooth_map(grid):
	var new_grid = []
	
	for y in range(grid.size()):
		var row = []
		
		for x in range(grid[y].size()):
			var neighbors = count_neighbors(grid, x, y)
			
			if neighbors >= 5:
				row.append(true)
			else:
				row.append(false)
		
		new_grid.append(row)
	
	return new_grid
	
#func generate
func generate_cave(seed: int):
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var grid = []

	for y in range(100):
		var row = []
		for x in range(100):
			row.append(rng.randf() > 0.4)
		grid.append(row)
		
	for i in range(4):
		grid = smooth_map(grid)

	return grid
