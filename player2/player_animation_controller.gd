class_name PlayerAnimationController

extends Node

const SHOT_PARAM = {
	GEnums.PlayerAnimShot.JUMP        : "parameters/jump/request",
	GEnums.PlayerAnimShot.LANDED      : "parameters/land/request",
	GEnums.PlayerAnimShot.LANDED_HARD : "parameters/land_hard/request",
	GEnums.PlayerAnimShot.ATTACK      : "parameters/attack/request",
	GEnums.PlayerAnimShot.HIT         : "parameters/hit/request",
	GEnums.PlayerAnimShot.DIE         : "parameters/die/request"
}

enum PlayerAnimState {
	IDLE, LYING, WALK, RUN, FLY, FALL
}

const STATE_ID = {
	PlayerAnimState.IDLE  : "idle",
	PlayerAnimState.LYING : "lying",
	PlayerAnimState.WALK  : "walk",
	PlayerAnimState.RUN   : "run",
	PlayerAnimState.FLY   : "fly",
	PlayerAnimState.FALL  : "fall"
}

const TRANSITION_REQUEST_PARAM = "parameters/state/transition_request"
const RUN_TIMESCALE_PARAM      = "parameters/run_timescale/scale"
const WALK_TIMESCALE_PARAM     = "parameters/walk_timescale/scale"

const WALK_TO_RUN_LIMIT = 50.0
const RUN_SCALE         = 1.0 / 60.0
const WALK_SCALE        = 1.0 / 12.0

@onready var sprite       = $Sprite2D
@onready var sprite_scale = sprite.scale.x

func _ready():
	$AnimationTree.active = true
	
func set_skin(skin_texture: Texture2D) -> void:
	for child in $Sprite2D/Polygons.get_children():
		if child is Polygon2D:
			child.texture = skin_texture

func play_shot(shot : GEnums.PlayerAnimShot) -> void:
	$AnimationTree[SHOT_PARAM[shot]] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func is_shot_active(shot : GEnums.PlayerAnimShot) -> bool:
	return $AnimationPlayer.current_animation == SHOT_PARAM[shot]

func play_die() -> void:
	play_shot(GEnums.PlayerAnimShot.DIE)
	$AnimationTree[TRANSITION_REQUEST_PARAM] = STATE_ID[PlayerAnimState.LYING]

func update_state(velocity : Vector2, is_on_floor : bool) -> void:
	if not is_zero_approx(velocity.x):
		sprite.scale.x = sprite_scale if velocity.x > 0.0 else -sprite_scale
	
	if is_on_floor:
		if is_zero_approx(velocity.x):
			$AnimationTree[TRANSITION_REQUEST_PARAM] = STATE_ID[PlayerAnimState.IDLE]
		elif abs(velocity.x) > WALK_TO_RUN_LIMIT:
			$AnimationTree[TRANSITION_REQUEST_PARAM] = STATE_ID[PlayerAnimState.RUN]
			$AnimationTree[RUN_TIMESCALE_PARAM]      = abs(velocity.x) * RUN_SCALE
		else:
			$AnimationTree[TRANSITION_REQUEST_PARAM] = STATE_ID[PlayerAnimState.WALK]
			$AnimationTree[WALK_TIMESCALE_PARAM]     = abs(velocity.x) * WALK_SCALE
	else:
		if velocity.y > 0.0:
			$AnimationTree[TRANSITION_REQUEST_PARAM] = STATE_ID[PlayerAnimState.FALL]
		else:
			$AnimationTree[TRANSITION_REQUEST_PARAM] = STATE_ID[PlayerAnimState.FLY]
