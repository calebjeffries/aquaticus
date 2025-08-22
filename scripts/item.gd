extends CharacterBody2D

signal collected

@export var texture: Texture

var sprite
var collider
var area_collider

func _ready():
	sprite = get_node("Sprite2D")
	collider = get_node("CollisionShape2D")
	area_collider = get_node("Area2D/CollisionShape2D")
	
	# Initialize size, position and texture
	sprite.texture = texture
	collider.shape.size.x = texture.get_width()
	collider.shape.size.y = texture.get_height()
	collider.position = sprite.position
	area_collider.shape.radius = round(texture.get_height() / 2 + 1)
	area_collider.shape.radius = 2 * (texture.get_width() + 1)
	area_collider.position = sprite.position

func _physics_process(delta: float):
	if velocity.length() < 1:
		velocity = Vector2.ZERO
		position = round(position) # If velocity is negligable, snap to grid
	else:
		velocity *= 1 - delta # Slow down
		move_and_collide(velocity)
		

# When collected, emit signal
func collect(body: Node):
	if body.name == "Player":
		collected.emit()
