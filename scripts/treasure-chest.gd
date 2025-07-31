extends Sprite2D

var gc

func _ready():
	gc = get_node('/root/Main')

# When the player is in range to open the chest, add the action
func _on_body_entered(body: Node2D):
	if body.name == "Player":
		gc.actions_available("open treasure chest", open)

# Clear actions if out of range
func _on_body_exited(body: Node2D):
	if body.name == "Player":
		gc.clear_actions()

# When the chest is opened
func open():
	gc.money_add(randi() % (10 * gc.rod_level) + 1) # Add a random amount of money
	queue_free() # Delete the chest
