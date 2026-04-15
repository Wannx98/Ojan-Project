
extends Resource
class_name Item

@export var id: String = ""         # unique id, contoh: "potion_small"
@export var display_name: String = ""
@export var icon: Texture2D        # tarik texture dari inspector
@export var max_stack: int = 0
@export var description: String = ""
@export var scene_path: String = ""   # optional: path ke scene item spawnable (res://...)

@export var item_type: String = ""
