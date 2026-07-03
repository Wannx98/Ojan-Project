extends Node2D

const PlayerScene = preload("res://Script/Character/PlayerMC/player_mc.tscn")
const MiniMapScene = preload("res://map/mini_map.tscn") # path MiniMap.tscn lo

@onready var my_tilemap = $TileMap
var player: CharacterBody2D = null
var minimap: MiniMap = null
var minimap_layer: CanvasLayer = null

func _ready():
	my_tilemap.generate_map()
	spawn_player()
	setup_minimap()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Global.current_cave_seed = -1
		my_tilemap.generate_map()
		spawn_player()
		setup_minimap() # refresh data minimap karena layout map berubah

func spawn_player():
	if player == null:
		player = PlayerScene.instantiate()
		add_child(player)
	player.global_position = my_tilemap.get_spawn_position()

func setup_minimap():
	if minimap == null:
		minimap_layer = CanvasLayer.new()
		add_child(minimap_layer)

		minimap = MiniMapScene.instantiate()
		minimap_layer.add_child(minimap)
		minimap.set_player(player)

	minimap.set_data(
		my_tilemap.get_room_rects_world(),
		my_tilemap.get_map_bounds_world()
	)
