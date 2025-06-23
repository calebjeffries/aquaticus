extends AnimatedSprite2D

var cameranode

var enabled = true
var xdirection = 0

@export var speed : float

func _ready():
	cameranode = get_node("../..")
	play_animation()

func _physics_process(delta: float) -> void:
	if enabled == true:
		if Input.is_action_pressed("left"):
			xdirection = -1
		elif Input.is_action_pressed("right"):
			xdirection = 1
		else:
			xdirection = 0
			cameranode.position = round(cameranode.position)
	else:
		xdirection = 0
		cameranode.position = round(cameranode.position)
	cameranode.position.x += speed * delta * xdirection
	play_animation()

func play_animation():
	if xdirection == 1:
		flip_h = 0
		play("walking")
	elif xdirection == -1:
		flip_h = 1
		play("walking")
	else:
		play("idle")
