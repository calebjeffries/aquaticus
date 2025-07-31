extends Camera2D

var player

func _ready():
	player = get_node("../Player")

# Follow the player
func _physics_process(delta: float):
	var difference = position - player.position # Calculate the difference
	var distance = sqrt(difference.x ** 2 + difference.y ** 2) # Get magnitude of difference
	var speed_multiplier = 2 - (2 / ((distance / 32) + 1)) # Use formula to ensure the camera doesn't get too far away
	position -= difference.normalized() * speed_multiplier * player.speed * delta # Move
