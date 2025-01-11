extends Enemy

@export var attack_distance: float = 6.0
@export var spin_speed_multiplier: float = 3.0

@onready var attack_animation: AnimationNodeAnimation = animation_tree.get_tree_root().get_node('AttackAnimation')
@onready var attack_timer: Timer = %AttackTimer

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spinning: bool = false
var _can_damage: bool = false

const simple_attacks: Dictionary = {
	'slice': '2H_Melee_Attack_Slice',
	'spin': '2H_Melee_Attack_Spin',
	'range': '1H_Melee_Attack_Stab'
}

func _physics_process(delta: float) -> void:
	move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	attack_timer.wait_time = rng.randf_range(4.0, 5.5)
	if position.distance_to(player.position) < attack_distance:
		melee_attack_animation()
	else:
		if rng.randi() % 2 == 0:
			range_attack_animation()
		else:
			spin_attack_animation()

func melee_attack_animation() -> void:
	set_attack_speed(0.5)
	attack_animation.animation = simple_attacks['slice' if rng.randi() % 2 == 0 else 'spin']
	animation_tree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func range_attack_animation() -> void:
	stop_movement(0.3, 1.5)
	set_attack_speed(1.0)
	attack_animation.animation = simple_attacks['range']
	animation_tree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func spin_attack_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", spin_speed_multiplier, 0.5)
	tween.tween_method(_spin_transition, 0.0, 1.0, 0.3)
	attack_timer.stop()
	spinning = true

	get_tree().create_timer(rng.randf_range(5.0, 10.0)).timeout.connect(func() -> void: _on_area_3d_body_entered(player))

func _spin_transition(value: float) -> void:
	animation_tree.set('parameters/SpinBlend/blend_amount', value)

func set_attack_speed(speed: float) -> void:
	animation_tree.set('parameters/AttackSpeed/scale', speed)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if spinning:
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
		var tween = create_tween()
		tween.tween_property(self, "speed_modifier", 1.0, 0.5)
		tween.tween_method(_spin_transition, 1.0, 0.0, 0.3)
		tween.finished.connect(func() -> void:
			spinning = false
			attack_timer.start()
		)

func _on_axe_hitbox_body_entered(body: Node3D) -> void:
	if (is_attacking() and _can_damage) or spinning:
		if body and 'hit' in body:
			body.hit()

func hit() -> void:
	if not invuln_timer.time_left:
		invuln_timer.start()
		print("Boss was hit")

func can_damage(value: bool) -> void:
	_can_damage = value