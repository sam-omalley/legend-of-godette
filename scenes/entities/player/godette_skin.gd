extends Node3D

@onready var move_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

func set_move_state(state_name: String) -> void:
	move_state_machine.travel(state_name)