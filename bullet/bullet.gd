class_name Bullet
extends RigidBody2D

@export  var damage: int = 30

@onready var animation_player := $AnimationPlayer as AnimationPlayer

func destroy() -> void:
	animation_player.play(&"destroy")

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		var diff = body.global_position - global_position
		(body as Enemy).take_damage(damage, diff)
		destroy()
