class_name StartMenu

extends Control

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var ai_button   := center_cont.get_node(^"VBoxContainer/PlayAsAIButton")    as Button
@onready var hu_button   := center_cont.get_node(^"VBoxContainer/PlayAsHumanButton") as Button

func _on_play_as_ai_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game/game_ai.tscn")

func _on_play_as_human_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game/game_human.tscn")
