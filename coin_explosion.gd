extends Node2D

var gc

var item_scene = preload("res://scenes/item.tscn")
var coin_bronze_texture = preload("res://images/items/coins/coin-bronze.png")
var coin_silver_texture = preload("res://images/items/coins/coin-silver.png")
var coin_gold_texture = preload("res://images/items/coins/coin-gold.png")

func _ready():
	gc = get_node("/root/Main")

# Emit coins in random directions
func explode(value):
	for childnum in value % 10: # Bronze coins for 1 dollar
		var item_node = item_scene.instantiate()
		item_node.texture = coin_bronze_texture
		item_node.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 2
		item_node.collected.connect(money_collected.bind(1, item_node))
		add_child(item_node)
	for childnum in (value % 100 - value % 10) / 10: # Silver coins for 10 dollars
		var item_node = item_scene.instantiate()
		item_node.texture = coin_silver_texture
		item_node.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 2
		item_node.collected.connect(money_collected.bind(10))
		add_child(item_node)
	for childnum in (value % 1000 - value % 100) / 100: # Gold coins for 100 dollars
		var item_node = item_scene.instantiate()
		item_node.texture = coin_gold_texture
		item_node.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 2
		item_node.collected.connect(money_collected.bind(100))
		add_child(item_node)

func money_collected(value: int, node: Node2D):
	gc.money_add(value)
	node.queue_free() # Delete money when collected
