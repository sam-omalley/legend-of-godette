extends Enemy

@export var attack_distance: float = 6.0

@onready var attack_animation: AnimationNodeAnimation = animation_tree.get_tree_root().get_node('AttackAnimation')
@onready var attack_timer: Timer = %AttackTimer

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const simple_attacks: Dictionary = {
	'slice': '2H_Melee_Attack_Slice',
	'range': '1H_Melee_Attack_Stab'
}

func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _on_attack_timer_timeout() -> void:
	attack_timer.wait_time = rng.randf_range(4.0, 5.5)
	if position.distance_to(player.position) < attack_distance:
		melee_attack_animation()

func melee_attack_animation() -> void:
	set_attack_speed(1.0)
	attack_animation.animation = simple_attacks['slice']
	animation_tree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func set_attack_speed(speed: float) -> void:
	animation_tree.set('parameters/AttackSpeed/scale', speed)
