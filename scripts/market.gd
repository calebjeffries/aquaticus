extends Node2D

var gc
var player_node
var inventory_node
var inventory_selector
var inventory_contents
var inventory_empty_text

var selected_inventory_fish = 0

func _ready():
	gc = get_node("/root/Main")
	inventory_node = get_node("CanvasLayer/Inventory")
	inventory_selector = inventory_node.get_node("Selector")
	inventory_contents = inventory_node.get_node("Contents")
	inventory_empty_text = inventory_node.get_node("Empty")

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

# Show market menu
func render_market():
	gc.get_player_node().enabled = false # Disable player controls
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
	gc.get_player_node().enabled = true # Enable movement
	enter_market_mode() # Go back to the option of entering the market

func enter_market_mode(_body: Node2D = null): # Add a market action
	gc.actions_available("sell fish", render_market)

func clear_mode(_body: Node2D = null): # Clear actions
	gc.clear_actions()
