extends Node2D

var gc
var fish_caught
var fish_caught_icon
var fish_caught_name
var fish_caught_weight
var fish_caught_length
var inventory_node
var inventory_selector
var inventory_contents
var inventory_empty_text
var inventory_full
var store_node
var store_level_text
var store_price_text
var player_node
var player_sprite

var fish_info
var selected_inventory_fish = 0
var fishing_direction

# Class for fish
class Fish:
	var name: String
	var weight: float
	var length: float
	var quality: int
	var texture: String
	func _init(fish_name: String, fish_weight: float, fish_length: float, fish_quality: int, fish_texture: String):
		name = fish_name
		weight = fish_weight
		length = fish_length
		quality = fish_quality
		texture = fish_texture

func _ready():
	# Assign nodes
	gc = get_node('/root/Main')
	fish_caught = get_node("Camera2D/FishCaught")
	fish_caught_icon = fish_caught.get_node("Icon")
	fish_caught_name = fish_caught.get_node("FishName")
	fish_caught_weight = fish_caught.get_node("Weight")
	fish_caught_length = fish_caught.get_node("Length")
	inventory_node = get_node("Camera2D/Inventory")
	inventory_selector = inventory_node.get_node("Selector")
	inventory_contents = inventory_node.get_node("Contents")
	inventory_empty_text = inventory_node.get_node("Empty")
	inventory_full = get_node("Camera2D/InventoryFull")
	store_node = get_node("Camera2D/Store")
	store_level_text = store_node.get_node("Level")
	store_price_text = store_node.get_node("Price")
	player_node = get_node("Player")
	player_sprite = player_node.get_node("Sprite")
	
	# Load fish information
	var json_file = "res://data/fish.json"
	var json_file_text = FileAccess.get_file_as_string(json_file)
	fish_info = JSON.parse_string(json_file_text)
	
	# Reset transparent nodes
	inventory_full.modulate.a = 0
	fish_caught.modulate.a = 0

# Process input to select fish in the market
func _input(event: InputEvent):
	if inventory_node.visible == true:
		if event.is_action_pressed("down"):
			if selected_inventory_fish < len(gc.inventory)-1:
				inventory_selector.position.y += 20
				selected_inventory_fish += 1
		elif event.is_action_pressed("up"):
			if selected_inventory_fish > 0:
				inventory_selector.position.y -= 20
				selected_inventory_fish -= 1

# Go fishing
func go_fishing():
	if player_node.fishing: # Exit if you're already fishing
		return
	if len(gc.inventory) >= 5: # Exit if your inventory is full
		inventory_full.get_node("AnimationPlayer").play("fade_out")
		return
	
	# Show fishing animation until a fish is caught
	player_sprite.flip_h = 0 if fishing_direction == 1 else 1 # Face player in the right direction
	player_node.start_fishing()
	await get_tree().create_timer(randf()).timeout
	player_node.stop_fishing()
	
	# Generate info about the catch
	var catch = fish_info.fish[randi_range(0, gc.rod_level-1)]
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
	gc.inventory.append(Fish.new(catch.name, weight, length, catch.quality, catch.texture))
	
	# Fade out the info box
	fish_caught.get_node("AnimationPlayer").stop()
	fish_caught.get_node("AnimationPlayer").play("fade_out")

# Show market menu
func render_market():
	player_node.enabled = false # Disable player controls
	gc.actions_available("sell", sell_fish, "exit", exit_market) # Add actions to sell or exit
	
	# Initiate variables
	var fishnum = 0
	selected_inventory_fish = 0
	
	# Render the menu
	inventory_node.visible = true
	inventory_selector.position.y = 24
	for child in inventory_contents.get_children(): # Remove previous children
		inventory_contents.remove_child(child)
		child.queue_free()
	if len(gc.inventory) == 0: # If the inventory is empty show the correct text
		inventory_empty_text.visible = true
		inventory_selector.visible = false
		inventory_node.size.y = 32
	else:
		inventory_empty_text.visible = false
		inventory_selector.visible = true
		for inventoryfish in gc.inventory: # Add all the fish as children
			var new_node = Sprite2D.new()
			new_node.texture = load(inventoryfish.texture)
			new_node.position.x = 26
			new_node.position.y = 24 + 20 * fishnum
			inventory_contents.add_child(new_node)
			fishnum += 1
		inventory_node.size.y = 18 + 20 * fishnum # Change size to fit the fish

# Sell fish from the inventory
func sell_fish():
	if len(gc.inventory) > 0:
		gc.money_add(gc.inventory[selected_inventory_fish].weight * gc.inventory[selected_inventory_fish].quality) # Add money
		gc.inventory.remove_at(selected_inventory_fish) # Remove the fish
		render_market() # Update display to remove the fish

# Leave the market
func exit_market():
	inventory_node.visible = false # Hide menu
	player_node.enabled = true # Enable movement
	enter_market_mode() # Go back to the option of entering the market

# Show the store menu
func render_store():
	player_node.enabled = false # Disable player controls
	gc.actions_available("upgrade", upgrade_rod, "exit", exit_store) # Add actions to buy or exit
	
	# Render the menu
	store_node.visible = true
	if gc.rod_level == len(fish_info.fish): # If no more upgrades are available, say MAX
		store_level_text.text = "lvl. " + str(gc.rod_level)
		store_price_text.text = "MAX"
		store_price_text.label_settings.font_color = Color(1, 0, 0, 1)
	else: # Otherwise, show the next level
		store_level_text.text = "lvl. " + str(gc.rod_level) + " > lvl. " + str(gc.rod_level + 1)
		var rodprice = get_rod_price(gc.rod_level + 1)
		store_price_text.text = "$" + str(rodprice) # Calculate and display price
		# Set text colour depending on if you have enough money
		if gc.money >= rodprice:
			store_price_text.label_settings.font_color = Color(0, 1, 0, 1)
		else:
			store_price_text.label_settings.font_color = Color(1, 0, 0, 1)

# Buy a rod upgrade
func upgrade_rod():
	if gc.rod_level < len(fish_info.fish) and gc.money >= get_rod_price(gc.rod_level + 1):
		gc.money_add(-get_rod_price(gc.rod_level + 1))
		gc.rod_level += 1
		render_store()

# Leave the store
func exit_store():
	store_node.visible = false # Hide menu
	player_node.enabled = true # Enable movement
	enter_store_mode() # Go back to the option of entering the market

# Calculate price
func get_rod_price(level) -> int:
	return 10  * (level - 1) ** 2

func enter_store_mode(_body: Node2D = null): # Add a store action
	gc.actions_available("enter store", render_store)

func enter_market_mode(_body: Node2D = null): # Add a market action
	gc.actions_available("sell fish", render_market)

func enter_fishing_mode(_body: Node2D, water_direction: int): # Add a fishing action
	fishing_direction = water_direction
	gc.actions_available("go fishing", go_fishing)

func clear_mode(_body: Node2D = null): # Clear actions
	gc.clear_actions()
