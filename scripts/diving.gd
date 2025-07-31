extends CharacterBody2D

@export var speed = 70
@export var breath_rate = 1

var underwater = false
var dead = false
var breath_value = 32

var gc
var sprite
var breath_bar

func _ready():
	gc = get_node("/root/Main")
	sprite = get_node("Sprite")
	breath_bar = get_node("BreathBar")

func _physics_process(delta: float):
	if not dead:
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
		
		# Decrease breath if underwater
		if underwater:
			breath_value -= breath_rate * delta
			breath_bar.value = breath_value
			if breath_value <= 0: # If you have no breath left, die
				dead = true
				gc.die()
		elif breath_value < 32: # If you're above water, refill air
			breath_value += 4 * breath_rate * delta
			breath_bar.value = breath_value
		else:
			breath_value = 32

# When player enters the underwater area, set the mode to underwater
func go_underwater(body: Node2D):
	if body.name == "Player":
		underwater = true

# When player leaves the underwater area, turn the underwater mode off
func go_above_water(body: Node2D):
	if body.name == "Player":
		underwater = false
