extends Node3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()


func _on_area_3d_body_entered(_body: Node3D) -> void:
	TimeManager.slow_motion(1.0, 0.2)
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().reload_current_scene()
