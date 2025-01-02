extends CharacterBody3D


# Movement settings
@export var base_speed: float = 10.0
@export var run_speed: float = 15.0
@export var acceleration: float = 100.0
@export var rotation_speed: float = 10.0

# Jump settings
@export var jump_height: float = 2.25
@export var jump_slow_multiplier: float = 0.4
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3
@export var jump_buffer_time: float = 0.1

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var skin: Node3D = $GodetteSkin

var jump_pressed: bool = false
var jump_buffer_timer: Timer

@onready var camera = $CameraController/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	jump_buffer_timer = Timer.new()
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.timeout.connect(func() -> void: jump_pressed = false)
	add_child(jump_buffer_timer)

func _physics_process(delta: float) -> void:
	jump_logic(delta)
	movement_logic(delta)

	move_and_slide()

func jump() -> void:
	velocity.y = -jump_velocity

func jump_logic(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= (jump_gravity if velocity.y > 0.0 else fall_gravity) * delta
		skin.set_move_state('Jump')
	
	# Jump whenever the jump button is pressed, or if we have recently buffered
	# a jump input.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		else:
			jump_pressed = true
			jump_buffer_timer.start(jump_buffer_time)
	elif jump_pressed and is_on_floor():
		jump_pressed = false
		jump_buffer_timer.stop()
		
		jump()
	
	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y *= jump_slow_multiplier

func movement_logic(delta: float) -> void:
	var movement_input: Vector2 = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var velocity_2d: Vector2 = Vector2(velocity.x, velocity.z)

	var is_running: bool = Input.is_action_pressed("run")

	if movement_input:
		velocity_2d += movement_input * acceleration * delta
		velocity_2d = velocity_2d.limit_length(run_speed if is_running else base_speed)
		if is_on_floor():
			skin.set_move_state('Running' if is_running else 'Walking')

		var target_angle: float = movement_input.angle()
		skin.rotation.y = rotate_toward(skin.rotation.y, -target_angle + PI/2, rotation_speed * delta)
	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, acceleration * delta)
		if is_on_floor():
			skin.set_move_state('Idle')
	velocity.x = velocity_2d.x
	velocity.z = velocity_2d.y
