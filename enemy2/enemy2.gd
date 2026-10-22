class_name Enemy2
extends CharacterBody2D

enum State {
	WALKING,
	HUNTING,
	DEAD
}

const WALK_SPEED = 40.0
const RUN_SPEED  = 300.0

const ATTACK_DISTANCE = 35.0
const STOP_HUNTING    = 200.0

const JUMP_VELOCITY = -725.0

var _state := State.WALKING

var _player_ref: Node2D = null

@onready var gravity: int          = ProjectSettings.get(&"physics/2d/default_gravity")
@onready var platform_detector    := $PlatformDetector   as RayCast2D
@onready var floor_detector_left  := $FloorDetectorLeft  as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var attack_timer         := $AttackAnimation    as Timer
@onready var AnimationController  := $Animation as PlayerAnimationController

func update_walking() -> void:
	if velocity.is_zero_approx():
		velocity.x = WALK_SPEED

	if not floor_detector_left.is_colliding():
		velocity.x = WALK_SPEED
	elif not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED

	if is_on_wall():
		velocity.x = -velocity.x

func update_hunting() -> void:
	if _player_ref == null:
		return

	var distance  = _player_ref.global_position - global_position

	if abs(distance.x) < ATTACK_DISTANCE:
		if attack_timer.is_stopped():
			AnimationController.play_shot(GEnums.PlayerAnimShot.ATTACK)
			attack_timer.start()
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

	AnimationController.update_state(velocity, is_on_floor())

func destroy() -> void:
	_state      = State.DEAD
	_player_ref = null
	velocity    = Vector2.ZERO


func _on_hunting_area_body_entered(body: Node2D) -> void:
	if _state == State.DEAD:
		return

	if body.is_in_group("Player"):
		_state      = State.HUNTING
		_player_ref = body
