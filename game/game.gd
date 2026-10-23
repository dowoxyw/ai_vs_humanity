class_name Game
extends Node

@export var enemy_skin : Texture2D
@export var player_skin: Texture2D

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu

func _ready() -> void:
	var player_node = get_node("Level/SkeletalPlayer")
	if player_node is Player:
		var animation = player_node.get_node(^"Animation")
		animation.set_skin(player_skin)

	var enemies_node = get_node("Level/Enemies")
	for child in enemies_node.get_children():
		if child is Enemy:
			var animation = child.get_node(^"Animation")
			animation.set_skin(enemy_skin)

func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()

	elif input_event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().root.set_input_as_handled()
