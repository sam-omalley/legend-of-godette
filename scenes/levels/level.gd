extends Node3D

@onready var projectiles: Node = %Projectiles
var fireball_scene: PackedScene = preload("res://scenes/vfx/fireball.tscn")

func _ready() -> void:
	%Player.death.connect(die)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	die()

func die() -> void:
	TimeManager.slow_motion(1.0, 0.2)
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().reload_current_scene()


func shoot_spell(type: int, pos: Vector3, direction: Vector3, size: float) -> void:
	if type == GameStateManager.Spells.FIREBALL:
		var fireball := fireball_scene.instantiate()
		projectiles.add_child(fireball)
		fireball.global_position = pos
		fireball.direction = direction
		fireball.setup(size)
