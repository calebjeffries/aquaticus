extends Node2D

var gc
var item_scene = preload("res://scenes/item.tscn")

func _ready():
	gc = get_node("/root/Main")
	if randi() % 2 == 1: # 50% percent chance of generating a bottom-dweller
		var type = randi() % min(len(gc.fish_info.bottomdwellers), gc.scuba_level) # Choose a type
		var item_node = item_scene.instantiate()
		var mollusk_texture = load(gc.fish_info.bottomdwellers[type].texture)
		item_node.texture = mollusk_texture
		item_node.position.y = -mollusk_texture.get_height() / 2 # Move sprite to the correct position
		item_node.collected.connect(collect_shellfish.bind(type))
		add_child(item_node) # Add the item to the scene

func collect_shellfish(type: int):
	var catch = gc.fish_info.bottomdwellers[type]
	var weight = randf_range(catch.weightmin, catch.weightmax) # Choose weight and length
	var length = randf_range(catch.lengthmin, catch.lengthmax)
	if gc.inventory_add(gc.Fish.new(catch.name, weight, length, catch.quality, catch.texture)):
		queue_free() # If there's space in the inventory, delete the node
