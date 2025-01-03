extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Movement/playback")


func set_move_state(state_name: String) -> void:
	move_state_machine.travel(state_name)

func set_move_speed(speed: float, max_speed: float) -> void:
	animation_tree.set("parameters/Movement/IdleWalkRun/blend_position", remap(speed, 0, max_speed, 0.0, 1.0))

func attack():
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)