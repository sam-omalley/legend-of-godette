extends Enemy

@export var attack_distance: float = 6.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const simple_attacks: Dictionary = {
    'slice': '2H_Melee_Attack_Slice',
    'spin': '2H_Melee_Attack_Spin',
    'range': '1H_Melee_Attack_Stab'
}

func _physics_process(delta: float) -> void:
    move_to_player(delta)


func _on_attack_timer_timeout() -> void:
    if position.distance_to(player.position) < attack_distance:
        melee_attack_animation()
    else:
        range_attack_animation()
	# 4 animations

    # 2 melee attacks

    # 2 range attacks

func melee_attack_animation() -> void:
    set_attack_speed(0.5)
    attack_animation.animation = simple_attacks['slice' if rng.randi() % 2 == 0 else 'spin'] 
    animation_tree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func range_attack_animation() -> void:
    stop_movement(0.3, 1.5)
    set_attack_speed(1.0)
    attack_animation.animation = simple_attacks['range']
    animation_tree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func set_attack_speed(speed: float) -> void:
    animation_tree.set('parameters/TimeScale/scale', speed)
