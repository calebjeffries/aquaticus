extends Node2D

var gc 
var store_node
var store_contents
var upgrade_selector

var selected_upgrade = 0

var store_label_settings = preload("res://resources/labelsettings/normal.tres")

@export var upgrades: Array[Upgrade]

func _ready():
	gc = get_node("/root/Main")
	store_node = get_node("CanvasLayer/Store")
	store_contents = store_node.get_node("Contents")
	upgrade_selector = store_node.get_node("Selector")

# Handle input to select from menu
func _input(event: InputEvent):
	if store_node.visible == true:
		if event.is_action_pressed("down"):
			if selected_upgrade < len(upgrades)-1:
				upgrade_selector.position.y += 32 # Move selector sprite down
				selected_upgrade += 1
		elif event.is_action_pressed("up"):
			if selected_upgrade > 0:
				upgrade_selector.position.y -= 32 # Move selector sprite up
				selected_upgrade -= 1

# Show the store menu
func render_store():
	gc.get_player_node().enabled = false # Disable player controls
	gc.actions_available("upgrade", upgrade_selected, "exit", exit_store) # Add actions to buy or exit
	selected_upgrade = 0
	
	# Show the menu
	store_node.visible = true
	upgrade_selector.position.y = 14
	for child in store_contents.get_children(): # Remove previous children
		store_contents.remove_child(child)
		child.queue_free()
	var upgrnum = 0
	while upgrnum < len(upgrades): # Add upgrades
		var upgr = upgrades[upgrnum]
		print(upgr.type)
		# Create node
		var new_node = Node2D.new()
		# Add sprite
		var texture_node = Sprite2D.new()
		texture_node.texture = upgrades[upgrnum].texture
		texture_node.position.x = 24
		texture_node.position.y = 24 + 32 * upgrnum
		new_node.add_child(texture_node)
		# Add level
		var level_node = Label.new()
		level_node.text = "lvl. " + str(get_level(upgr.type))
		if not is_max_level(upgr.type):
			level_node.text += " > lvl. " + str(get_level(upgr.type) + 1)
		level_node.label_settings = store_label_settings
		level_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_node.size = Vector2(68, 12)
		level_node.position.x = 6
		level_node.position.y = 32 * (upgrnum + 1)
		new_node.add_child(level_node)
		# Add price
		var price_node = Label.new()
		price_node.label_settings = store_label_settings.duplicate()
		if is_max_level(upgr.type):
			price_node.text = "MAX"
			price_node.label_settings.font_color = Color(1, 0, 0, 1)
		else:
			var price = get_price(get_level(upgr.type) + 1, upgr.price_exponent, upgr.price_multiplier)
			price_node.text = "$" + str(price) # Calculate and display price
			# Set text colour depending on if you have enough money
			if gc.money >= price:
				price_node.label_settings.font_color = Color(0, 1, 0, 1)
			else:
				price_node.label_settings.font_color = Color(1, 0, 0, 1)
		price_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_node.size = Vector2(40, 15)
		price_node.position.x = 40
		price_node.position.y = 18 + 32 * upgrnum
		new_node.add_child(price_node)
		# Add to scene
		store_contents.add_child(new_node)
		upgrnum += 1
	# Resize menu accordingly
	store_node.size.y = 16 + 32 * upgrnum # Change size to fit the fish

# Buy a rod upgrade
func upgrade_selected():
	var upgr = upgrades[selected_upgrade]
	if not is_max_level(upgr.type) and gc.money >= get_price(get_level(upgr.type) + 1, upgr.price_exponent, upgr.price_multiplier):
		gc.money_add(-get_price(get_level(upgr.type) + 1, upgr.price_exponent, upgr.price_multiplier))
		if upgr.type == "rod":
			gc.rod_level += 1
		elif upgr.type == "scuba":
			gc.scuba_level += 1
		elif upgr.type == "inventory":
			gc.inventory_size += 1
		render_store()

# Calculate price
func get_price(level: int, exponent: float, multiplier: float) -> int:
	return int(multiplier  * exponent ** (level - 2))

# Get the current level
func get_level(type: String) -> int:
	if type == "rod":
		return gc.rod_level
	elif type == "scuba":
		return gc.scuba_level
	elif type == "inventory":
		return gc.inventory_size - 3
	return 0

# Check if the max upgrade has been reached
func is_max_level(type: String) -> bool:
	var level = get_level(type)
	if type == "rod":
		return level >= len(gc.fish_info.saltwater)
	elif type == "scuba":
		return level >= len(gc.fish_info.bottomdwellers)
	elif type == "inventory":
		return level >= gc.inventory_max_size
	return 0

# Leave the store
func exit_store():
	store_node.visible = false # Hide menu
	gc.get_player_node().enabled = true # Enable movement
	enter_store_mode() # Go back to the option of entering the market

func enter_store_mode(_body: Node2D = null): # Add a store action
	gc.actions_available("enter store", render_store)
	
func clear_mode(_body: Node2D = null): # Clear actions
	gc.clear_actions()
