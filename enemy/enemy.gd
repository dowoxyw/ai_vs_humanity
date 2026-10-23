class_name Enemy

extends CharacterBody2D

enum State {
	WALKING,
	HUNTING,
	DEAD
}

signal health_changed

const WALK_SPEED = 40.0
const RUN_SPEED  = 300.0

const ATTACK_DISTANCE = 35.0
const STOP_HUNTING    = 200.0

const JUMP_VELOCITY = -725.0
const HIT_VELOCITY  = -225.0

var _state := State.WALKING

@export  var health_capacity: int = 100
var health_value : int = health_capacity

@export  var damage: int = 10

var _player_ref: Node2D = null

var direction : float = 1.0

@onready var gravity: int          = ProjectSettings.get(&"physics/2d/default_gravity")
@onready var platform_detector    := $PlatformDetector   as RayCast2D
@onready var floor_detector_left  := $FloorDetectorLeft  as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var attack_timer         := $AttackAnimation    as Timer
@onready var shock_cooldown       := $ShockCooldown      as Timer
@onready var AnimationController  := $Animation as PlayerAnimationController
@onready var hit_detector         := $Animation/Sprite2D/HitDetector as RayCast2D

func get_health_capacity() -> int:
	return health_capacity

func get_health() -> int:
	return health_value

func update_walking() -> void:
	if not is_zero_approx(velocity.x):
		direction = 1.0 if velocity.x > 0.0 else -1.0
		
	if abs(velocity.x) > WALK_SPEED:
		velocity.x = sign(velocity.x) * WALK_SPEED

	if abs(velocity.x) < WALK_SPEED and shock_cooldown.is_stopped():
		velocity.x = sign(velocity.x if velocity.x != 0.0 else direction) * WALK_SPEED

	if not floor_detector_left.is_colliding():
		velocity.x = WALK_SPEED
	elif not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED

	if is_on_wall():
		velocity.x = -velocity.x

func update_hunting() -> void:
	if _player_ref == null:
		return

	var distance = _player_ref.global_position - global_position

	if abs(distance.x) < ATTACK_DISTANCE:
		if attack_timer.is_stopped():
			AnimationController.play_shot(GEnums.PlayerAnimShot.ATTACK)
			attack_timer.start()
			if hit_detector.is_colliding():
				var collider = hit_detector.get_collider()
				if collider.is_in_group("Player"):
					var diff = collider.global_position - global_position
					collider.take_damage(damage, diff)
		velocity.x = 0.0
		return
	elif distance.length() > STOP_HUNTING:
		_state      = State.WALKING
		_player_ref = null
		velocity.x  = 0.0

	velocity.x = sign(distance.x) * RUN_SPEED

	if is_on_floor() and (not floor_detector_left.is_colliding() or not floor_detector_right.is_colliding()):
		velocity.y = JUMP_VELOCITY

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	match _state:
		State.WALKING :
			update_walking()
		State.HUNTING :
			update_hunting()

	move_and_slide()

	if _state == State.DEAD:
		return

	AnimationController.update_state(velocity, is_on_floor())

func take_damage(damage: int, diff: Vector2) -> void:
	if _state == State.DEAD:
		return

	health_value -= damage
	health_changed.emit()

	if health_value <= 0:
		health_value = 0
		AnimationController.play_die()
		die()
	else:
		velocity.x = sign(diff.x) * -1.0
		velocity.y = HIT_VELOCITY
		AnimationController.play_shot(GEnums.PlayerAnimShot.HIT)
		shock_cooldown.start()

func die() -> void:
	$ProgressBar.visible = false

	_state      = State.DEAD
	_player_ref = null
	velocity    = Vector2.ZERO

	set_collision_layer_value(2, false)

func _on_hunting_area_body_entered(body: Node2D) -> void:
	if _state == State.DEAD:
		return

	if body.is_in_group("Player"):
		_state      = State.HUNTING
		_player_ref = body
