extends Node3D

@onready var projectiles: Node3D = %Projectiles
var fireball_scene: PackedScene = preload("res://scenes/vfx/fireball.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()


func _on_area_3d_body_entered(_body: Node3D) -> void:
	TimeManager.slow_motion(1.0, 0.2)
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().reload_current_scene()


func _on_player_cast_spell(type: String, pos: Vector3, direction: Vector3, size: float) -> void:
	print("Shoot fireball")
	var fireball := fireball_scene.instantiate()
	projectiles.add_child(fireball)
	fireball.global_position = pos
	fireball.direction = direction
