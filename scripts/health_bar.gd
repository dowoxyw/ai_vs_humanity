extends ProgressBar

@export var Entity: Node

func _ready() -> void:
	if Entity.has_signal("health_changed"):
		Entity.health_changed.connect(update_value)

	update_value()

func update_value() -> void:
	if Entity != null and Entity.has_method("get_health_capacity") and Entity.has_method("get_health"):
		value = Entity.get_health() * 100.0 / Entity.get_health_capacity()
	release_focus()
