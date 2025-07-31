extends Node2D

# Class for fish
class Fish:
	var name: String
	var weight: float
	var length: float
	var quality: int
	var texture: String
	func _init(fish_name: String, fish_weight: float, fish_length: float, fish_quality: int, fish_texture: String):
		name = fish_name
		weight = fish_weight
		length = fish_length
		quality = fish_quality
		texture = fish_texture

var money = 0
var inventory = []
var rod_level = 1
var dead = false

var action1_func
var action2_func

var initial_scene = preload("res://scenes/on-land.tscn")
var actions_bar
var actions_bar_text
var money_node
var fade_out_player

func _ready():
	actions_bar = get_node("CanvasLayer/UI/ActionsBar")
	actions_bar_text = get_node("CanvasLayer/UI/ActionsBar/Label")
	money_node = get_node("CanvasLayer/UI/Money")
	fade_out_player = get_node("CanvasLayer/UI/ColorRect/AnimationPlayer")
	add_child(initial_scene.instantiate()) # Load initial scene

# Process input if there are actions available
func _input(event: InputEvent):
	if event.is_action_pressed("select") and action1_func:
		action1_func.call()
	elif event.is_action_pressed("quit") and action2_func:
		action2_func.call()

# Switches scene when you die
func _physics_process(_delta: float):
	if dead and not fade_out_player.is_playing():
		switch_scene("res://scenes/on-land.tscn")
		fade_out_player.play("RESET") # Reset the transparency
		dead = false

# Get available actions and display them on the action bar
func actions_available(action1_name: String, action1_function: Callable, action2_name = "", action2_function = null):
	# Set action bar text
	actions_bar_text.text = "[E] " + action1_name
	if action2_name: # If two actions are given assign the other one to [Q]
		actions_bar_text.text += " : [Q] " + action2_name
	actions_bar.visible = true
	
	# Assign callbacks for when actions are taken
	action1_func = action1_function
	action2_func = action2_function

# Clear actions and hide actions bar
func clear_actions():
	actions_bar_text.text = ""
	actions_bar.visible = false
	action1_func = null
	action2_func = null

# Add money and update the text
func money_add(amount: float):
	money += amount
	money = snapped(money, 0.01) # Snap to the value of pennies
	money_node.update() # Update text

# Die and respawn
func die():
	dead = true
	money = 0 # Loose all money
	money_node.update()
	inventory = [] # Loose inventory
	fade_out_player.play("fade_out") # Fade out

# Switch to another scene
func switch_scene(path: String):
	# Lambda function to change scene
	var switch_scene_hard = func(scene_path: String):
		for child in get_children(): # Remove all children except for the UI
			if child.name != "CanvasLayer":
				child.queue_free()
		add_child(load(scene_path).instantiate()) # Add the new scene
	
	# Wait until no physics processes are being run to switch scenes
	switch_scene_hard.call_deferred(path)
