extends Sprite2D

var gc
var coin_explosion = preload("res://scenes/coin_explosion.tscn")

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
	var coins = coin_explosion.instantiate()
	coins.position = position
	coins.explode(randi() % (10 * gc.rod_level ** 2) + 1) # Create a random amount of coins
	add_sibling(coins) # Make a coin explosion
	queue_free() # Delete the chest
