extends Node3D

@export var defend_duration: float = 0.25

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Movement/playback")
@onready var attack_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/AttackStateMachine/playback")
@onready var second_attack_timer: Timer = %SecondAttackTimer
@onready var third_attack_timer: Timer = %ThirdAttackTimer
@onready var attack_buffer: Timer = %AttackBuffer

@onready var weapon_sword: Node3D = %Sword
@onready var weapon_wand: Node3D = %Wand
@onready var spell_marker: Marker3D = %SpellMarker

const faces: Dictionary = {
	'default': Vector3(0.0, 0.0, 0.0),
	'blink': Vector3(0.0, 0.5, 0.0),
	'happy': Vector3(0.5, 0.0, 0.0),
	'angry': Vector3(0.5, 0.5, 0.0),
}
@onready var face_material: StandardMaterial3D = $Rig/Skeleton3D/Godette_Head.get_surface_override_material(0)

var squash_and_stretch: float = 1.0:
	set(value):
		squash_and_stretch = value
		var negative: float = 1.0 + (1.0 - squash_and_stretch)
		scale = Vector3(negative, squash_and_stretch, negative)

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var attack_requested: bool = false
func _ready() -> void:
	attack_buffer.timeout.connect(func() -> void:
		if attack_requested:
			attack()
	)

func set_move_state(state_name: String) -> void:
	move_state_machine.travel(state_name)

func set_move_speed(speed: float, max_speed: float) -> void:
	animation_tree.set("parameters/Movement/IdleWalkRun/blend_position", remap(speed, 0, max_speed, 0.0, 1.0))

func attack():
	if not is_attacking():
		attack_requested = false
		if third_attack_timer.time_left:
			animation_tree.set_attack_animation(3)
		elif second_attack_timer.time_left:
			animation_tree.set_attack_animation(2)
		else:
			animation_tree.set_attack_animation(1)
		animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else:
		attack_requested = true
		attack_buffer.start()

func defend(forward: bool) -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), defend_duration)

func _defend_change(value: float) -> void:
	animation_tree.set("parameters/ShieldBlend/blend_amount", value)

func is_attacking() -> bool:
	return animation_tree.get("parameters/AttackOneShot/active")

func switch_weapon(weapon_active: bool) -> void:
	weapon_sword.set_visible(weapon_active)
	weapon_wand.set_visible(not weapon_active)

	animation_tree.set_weapon_active(weapon_active)

func cast_spell() -> void:
	if not is_attacking():
		animation_tree.set_attack_animation(1)
		animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shoot_magic() -> void:
	get_parent().shoot_magic(spell_marker.global_position)
	
func hit() -> void:
	# Change extra animation hit_A
	var hit_amount: float = randf_range(-1.0, 1.0)
	animation_tree.set("parameters/HitAnimation/blend_position", hit_amount)

	animation_tree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func change_face(expression: String) -> void:
	face_material.uv1_offset = faces[expression]


func _on_blink_timer_timeout() -> void:
	change_face('blink')
	await get_tree().create_timer(0.2).timeout
	change_face('default')
	$Timers/BlinkTimer.wait_time = rng.randf_range(1.5, 3.0)

func can_damage(value: bool) -> void:
	weapon_sword.can_damage = value
