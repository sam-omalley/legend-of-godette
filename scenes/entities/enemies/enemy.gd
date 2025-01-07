class_name Enemy
extends CharacterBody3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group('Player')
@onready var skin := get_node('Skin')
@onready var animation_tree: AnimationTree = %AnimationTree

@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var turn_speed: float = 6.0
@export var notice_radius: float = 30.0
@export var attack_radius: float = 4.0

var speed_modifier: float = 1.0
func stop_movement(start_duration: float, end_duration: float) -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "speed_modifier", 0.0, start_duration)
    tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func move_to_player(delta: float) -> void:
    if position.distance_to(player.position) < notice_radius: # and not is_attacking():
        var target_dir = (player.position - position).normalized()
        var target_distance = position.distance_to(player.position)

        var target_vec2 = Vector2(target_dir.x, target_dir.z)
        var target_angle = -target_vec2.angle() + PI / 2
        rotation.y = rotate_toward(rotation.y, target_angle, delta * turn_speed)

        if target_distance <= attack_radius:
            target_vec2 = Vector2.ZERO
        velocity = Vector3(target_vec2.x, 0, target_vec2.y) * walk_speed * speed_modifier
        
        # Enemy should move faster when further away.
        set_move_speed(remap(target_distance, attack_radius, notice_radius, 0, run_speed), run_speed)
        
        move_and_slide()
    else:
        set_move_speed(0, walk_speed)

func set_move_speed(speed: float, max_speed: float) -> void:
    animation_tree.set("parameters/IdleWalkRun/blend_position", remap(speed, 0, max_speed, 0.0, 1.0))

func is_attacking() -> bool:
    return animation_tree.get("parameters/AttackOneShot/active")