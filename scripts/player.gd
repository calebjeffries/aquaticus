extends CharacterBody2D

var gc
var sprite_node
var collision_node

var enabled = true
var fishing = false
var walking_direction = 0
var boat_direction
var original_position

@export var speed : float

func _ready():
	gc = get_node("/root/Main")
	sprite_node = get_node("Sprite")
	collision_node = get_node("CollisionShape2D")
	play_animation() # Start animation

# Movement
func _physics_process(_delta: float):
	if fishing == true:
		return
	if gc.in_boat:
		# Get direction from input
		boat_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
		
		if boat_direction:
			velocity = boat_direction.normalized() * speed
			move_and_slide() # Move if there's input
		else:
			position = round(position) # Otherwise, snap to the pixels
		play_animation() # Play correct animation
	elif enabled == true:
		# Get direction from input
		walking_direction = Input.get_axis("left", "right")
		if walking_direction:
			velocity.x = walking_direction * speed
			move_and_slide() # Move if there's input
		else:
			position = round(position) # Otherwise, snap to the pixels
		play_animation() # Play correct animation
	elif enabled == false:
		sprite_node.play("idle") # Play idle animation if movement is disabled

# Play correct animation in the correct direction
func play_animation():
	if not gc.in_boat:
		if walking_direction > 0:
			sprite_node.flip_h = 0
			sprite_node.play("walking")
		elif walking_direction < 0:
			sprite_node.flip_h = 1
			sprite_node.play("walking")
		else:
			sprite_node.play("idle")
	else:
		if boat_direction.length() > 0:
			sprite_node.play("boat")
			if boat_direction.x < 0:
				rotation = 3*PI/2
			elif boat_direction.x > 0:
				rotation = PI/2
			elif boat_direction.y > 0:
				rotation = PI
			elif boat_direction.y < 0:
				rotation = 0
		else:
			sprite_node.play("boat-idle")

func start_fishing():
	rotation = 0
	original_position = position # Save position for when you stop fishing
	if gc.in_boat: # Play animation and move to compensate for a different sprite
		sprite_node.play("boat-fishing")
		position.x = original_position.x + 16
		position.y = original_position.y - 8
	else:
		position.x = original_position.x + 20
		sprite_node.play("fishing")
	fishing = true # Stop movement and set state

func stop_fishing():
	if gc.in_boat: # Play correct animation
		sprite_node.play("boat-idle")
	else:
		sprite_node.play("idle")
	position = original_position # Move to original position with the smaller sprite
	fishing = false # Go back to original controls
