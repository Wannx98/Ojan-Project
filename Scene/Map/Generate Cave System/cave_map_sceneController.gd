extends Node2D

var seed = 123

func _ready():
	var cave = GenerateCaveSystem.get_cave(seed)
	$CaveRenderer.render_cave(cave)
