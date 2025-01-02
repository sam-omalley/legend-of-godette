extends Node3D

@export var horizontal_acceleration: float = 2.0
@export var vertical_acceleration: float = 1.0
@export var mouse_acceleration: float = 0.005

@export var limit_x: Vector2 = Vector2(-0.8, -0.2)

#func _process(delta: float) -> void:
	# var joy_dir = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	# rotate_from_vector(joy_dir * delta * Vector2(horizontal_acceleration, vertical_acceleration))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * mouse_acceleration)

func rotate_from_vector(v: Vector2) -> void:
	if v.length() == 0: return

	rotation.y -= v.x
	rotation.x -= v.y
	rotation.x = clamp(rotation.x, limit_x.x, limit_x.y)