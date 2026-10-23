class_name FinalPerson

extends CharacterBody2D

signal game_over

@onready var speech_timer := $SpeechAnimation as Timer

func hide_speeches() -> void:
	$ContinueText.visible = false
	$FinalText   .visible = false

func _ready() -> void:
	hide_speeches()
	
func check_enemies_alive() -> bool:
	var enemies = get_tree().get_nodes_in_group("enemies")
	return enemies.size() > 0

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if check_enemies_alive():
			$ContinueText.visible = true
		else:
			game_over.emit()
			$FinalText.visible = true

		speech_timer.start()

func _on_speech_animation_timeout() -> void:
	hide_speeches()
