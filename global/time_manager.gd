class_name HitStopManager
extends Node

func hit_stop(duration: float):
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func slow_motion(duration: float, slow: float) -> void:
	Engine.time_scale = slow
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
