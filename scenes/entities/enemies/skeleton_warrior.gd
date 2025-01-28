extends Enemy

@export var attack_distance: float = 6.0

@onready var attack_animation: AnimationNodeAnimation = animation_tree.get_tree_root().get_node('AttackAnimation')
@onready var attack_timer: Timer = %AttackTimer

@onready var bone_left: Node3D = %BoneLeft
@onready var bone_right: Node3D = %BoneRight

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const simple_attacks: Dictionary = {
	'slice': 'Dualwield_Melee_Attack_Slice'
}

func _ready() -> void:
	$Skin/Rig/Skeleton3D/Skeleton_Warrior_Body.material_overlay.set_shader_parameter('alpha', 0.0)

func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _on_attack_timer_timeout() -> void:
	attack_timer.wait_time = rng.randf_range(2.0, 4.0)
	if position.distance_to(player.position) < attack_distance:
		melee_attack_animation()

func melee_attack_animation() -> void:
	set_attack_speed(1.0)
	attack_animation.animation = simple_attacks['slice']
	animation_tree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func set_attack_speed(speed: float) -> void:
	animation_tree.set('parameters/AttackSpeed/scale', speed)

func can_damage(value: bool) -> void:
	bone_left.can_damage = value
	bone_right.can_damage = value

func hit_effect(value: float) -> void:
	$Skin/Rig/Skeleton3D/Skeleton_Warrior_Body.material_overlay.set_shader_parameter('alpha', value)
