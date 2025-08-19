extends Node2D

var gc
var empty_boat_node

func _ready():
	gc = get_node("/root/Main")
	empty_boat_node = get_node("EmptyBoat")

func _physics_process(_delta: float) -> void:
	if gc.in_boat: # Hide empty boat sprite if the player is in the boat
		empty_boat_node.visible = false
	else:
		empty_boat_node.visible = true

func toggle_boat_mode(body: Node2D):
	if body.name == "Player":
		if gc.in_boat: # If the player is already in the boat
			gc.in_boat = false
			body.sprite_node.play("idle") # Change sprite
			body.collision_node.shape.size = Vector2(8, 28) # Change player size and position
			body.collision_node.position.y = 32
			body.sprite_node.position.y = 32
			body.position = position + Vector2(0, -40)
			body.rotation = 0
			body.velocity = Vector2.ZERO
		else: # If the player is already isn't in the boat
			gc.in_boat = true
			body.sprite_node.play("boat") # Change sprite
			body.collision_node.shape.size = Vector2(30, 30) # Change player size and position
			body.collision_node.position.y = 1
			body.sprite_node.position.y = 0
			body.position = position + Vector2(-36 * scale.x, 0)
