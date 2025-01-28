extends Enemy

@export var attack_distance: float = 12.0

@onready var attack_animation: AnimationNodeAnimation = animation_tree.get_tree_root().get_node('AttackAnimation')
@onready var attack_timer: Timer = %AttackTimer

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const simple_attacks: Dictionary = {
	'spell': 'Spellcast_Long'
}

func _ready() -> void:
	$Skin/Rig/Skeleton3D/Skeleton_Mage_Body.material_overlay.set_shader_parameter('alpha', 0.0)

func _physics_process(delta: float) -> void:
	move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	attack_timer.wait_time = rng.randf_range(4.0, 5.5)
	if position.distance_to(player.position) < attack_distance:
		spell_attack_animation()

func spell_attack_animation() -> void:
	stop_movement(0.3, 1.5)
	set_attack_speed(1.0)
	attack_animation.animation = simple_attacks['spell']
	animation_tree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func set_attack_speed(speed: float) -> void:
	animation_tree.set('parameters/AttackSpeed/scale', speed)

func hit_effect(value: float) -> void:
	$Skin/Rig/Skeleton3D/Skeleton_Mage_Body.material_overlay.set_shader_parameter('alpha', value)
