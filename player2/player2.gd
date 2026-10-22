class_name MyPlayer

extends CharacterBody2D

const WALK_SPEED         = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY      = -725.0

const TERMINAL_VELOCITY = 700

@export var action_suffix: String = ""

var gravity: int = ProjectSettings.get(&"physics/2d/default_gravity")

@onready var platform_detector   := $PlatformDetector as RayCast2D
@onready var jump_sound          := $Jump      as AudioStreamPlayer2D
@onready var camera              := $Camera    as Camera2D
@onready var AnimationController := $Animation as PlayerAnimationController

@onready var shoot_timer := $ShootAnimation   as Timer
@onready var gun: Gun     = $Animation/Sprite2D/Gun

var _double_jump_charged: bool  = false
var gun_direction       : float = 1.0

func _physics_process(delta: float) -> void:
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	if is_on_floor():
		_double_jump_charged = true
	if Input.is_action_just_pressed("jump" + action_suffix):
		if try_jump():
			AnimationController.play_shot(GEnums.PlayerAnimShot.JUMP)
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6

	if not is_zero_approx(velocity.x):
		gun_direction = 1.0 if velocity.x > 0.0 else -1.0

	if Input.is_action_just_pressed("shoot" + action_suffix) and shoot_timer.is_stopped():
		AnimationController.play_shot(GEnums.PlayerAnimShot.ATTACK)
		gun.shoot(gun_direction)
		shoot_timer.start()

	AnimationController.update_state(velocity, is_on_floor())

func try_jump() -> bool:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return false

	velocity.y = JUMP_VELOCITY
	jump_sound.play()
	return true
