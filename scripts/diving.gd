extends CharacterBody2D

@export var speed = 70

var sprite

func _ready():
	sprite = get_node("Sprite")

func _physics_process(_delta: float):
	# Get direction from input
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	
	if direction:
		velocity = direction.normalized() * speed
		move_and_slide() # Move if there's input
	else:
		position = round(position) # Otherwise, snap to the pixels
	
	# Point the sprite in the right direction
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
