extends CharacterBody2D

var sprite_node

var enabled = true
var fishing = false
var direction = 0
var original_position

@export var speed : float

func _ready():
	sprite_node = get_node("Sprite")
	play_animation() # Start animation

# Movement
func _physics_process(_delta: float):
	if enabled == true and fishing == false:
		# Get direction from input
		direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * speed
			move_and_slide() # Move if there's input
		else:
			position = round(position) # Otherwise, snap to the pixels
		play_animation() # Play correct animation
	elif enabled == false:
		sprite_node.play("idle") # Play idle animation if movement is disabled

# Play correct animation in the correct direction
func play_animation():
	if direction > 0:
		sprite_node.flip_h = 0
		sprite_node.play("walking")
	elif direction < 0:
		sprite_node.flip_h = 1
		sprite_node.play("walking")
	else:
		sprite_node.play("idle")

func start_fishing():
	original_position = position.x # Save position for when you stop fishing
	position.x = original_position + 20 # Move ahead to compensate for the bigger sprite
	sprite_node.play("fishing") # Play animation
	fishing = true # Stop movement and set state

func stop_fishing():
	sprite_node.play("idle") # Play idle animation
	position.x = original_position # Move to original position with the smaller sprite
	fishing = false # Go back to original controls
