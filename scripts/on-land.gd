extends Node2D

var gc
var fish_caught
var fish_caught_icon
var fish_caught_name
var fish_caught_weight
var fish_caught_length
var store_node
var store_level_text
var store_price_text
var player_node
var player_sprite

var current_available_fish
var fishing_direction

func _ready():
	# Assign nodes
	gc = get_node('/root/Main')
	fish_caught = get_node("Camera2D/FishCaught")
	fish_caught_icon = fish_caught.get_node("Icon")
	fish_caught_name = fish_caught.get_node("FishName")
	fish_caught_weight = fish_caught.get_node("Weight")
	fish_caught_length = fish_caught.get_node("Length")
	player_node = get_node("Player")
	player_sprite = player_node.get_node("Sprite")
	
	# Reset transparent node
	fish_caught.modulate.a = 0

# Go fishing
func go_fishing():
	if player_node.fishing: # Exit if you're already fishing
		return
	if len(gc.inventory) >= gc.inventory_size: # Exit if your inventory is full
		gc.show_inventory_full()
		return
	
	# Show fishing animation until a fish is caught
	player_sprite.flip_h = 0 if fishing_direction == 1 else 1 # Face player in the right direction
	player_node.start_fishing()
	await get_tree().create_timer(randf()).timeout
	player_node.stop_fishing()
	
	# Generate info about the catch
	var catch = current_available_fish[randi_range(0, gc.rod_level-1)]
	var weight = randf_range(catch.weightmin, catch.weightmax)
	var length = randf_range(catch.lengthmin, catch.lengthmax)
	
	# Render info box about the catch
	fish_caught.visible = true
	fish_caught_icon.texture = load(catch.texture)
	fish_caught_name.text = catch.name.capitalize()
	if weight >= 1: # Use units that make sense
		fish_caught_weight.text = str(int(round(weight))) + "kg"
	else:
		fish_caught_weight.text = str(int(round(weight * 1000))) + "g"
	fish_caught_length.text = str(int(round(length))) + "cm"
	gc.inventory_add(gc.Fish.new(catch.name, weight, length, catch.quality, catch.texture))
	
	# Fade out the info box
	fish_caught.get_node("AnimationPlayer").stop()
	fish_caught.get_node("AnimationPlayer").play("fade_out")

func enter_fishing_mode(_body: Node2D, water_direction: int, type: String): # Add a fishing action
	if type == "fresh": # Choose the right fish for the location
		current_available_fish = gc.fish_info.freshwater
	elif type == "salt":
		current_available_fish = gc.fish_info.saltwater
	else:
		assert("invalid water type")
	fishing_direction = water_direction
	gc.actions_available("go fishing", go_fishing)

func clear_mode(_body: Node2D = null): # Clear actions
	gc.clear_actions()
