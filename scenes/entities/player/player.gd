extends CharacterBody3D


# Movement settings
@export var base_speed: float = 10.0
@export var run_speed: float = 15.0
@export var defend_speed: float = 5.0
@export var speed_modifier: float = 1.0
@export var acceleration: float = 40.0
@export var deacceleration: float = 80.0
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
@onready var camera = $CameraController/Camera3D

var jump_pressed: bool = false
var jump_buffer_timer: Timer

var defend: bool = false:
	set(value):
		if defend != value:
			skin.defend(value)
		defend = value
	
var weapon_active: bool = true


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	jump_buffer_timer = Timer.new()
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.timeout.connect(func() -> void: jump_pressed = false)
	add_child(jump_buffer_timer)

	skin.switch_weapon(weapon_active)

func _physics_process(delta: float) -> void:
	jump_logic(delta)
	movement_logic(delta)
	animation_state_update()
	ability_logic()

	if Input.is_action_just_pressed("ui_accept"):
		skin.hit()
		stop_movement(0.3, 0.3)

	move_and_slide()

func animation_state_update() -> void:
	if is_on_floor():
		skin.set_move_state('IdleWalkRun')
	else:
		skin.set_move_state('Jump')

func jump() -> void:
	velocity.y = -jump_velocity
	do_squash_and_stretch(1.1, 0.15)

func jump_logic(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= (jump_gravity if velocity.y > 0.0 else fall_gravity) * delta
	
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
	var is_running: bool = Input.is_action_pressed("run")
	var movement_input: Vector2 = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var velocity_2d: Vector2 = Vector2(velocity.x, velocity.z)

	var speed: float = base_speed
	if is_running:
		speed = run_speed
	if defend:
		speed = defend_speed

	if movement_input:
		velocity_2d += movement_input * acceleration * delta
		#velocity_2d = velocity_2d.limit_length(speed)
		velocity_2d = velocity_2d.move_toward(velocity_2d.limit_length(speed), deacceleration * delta)

		var target_angle: float = movement_input.angle()
		skin.rotation.y = rotate_toward(skin.rotation.y, -target_angle + PI/2, rotation_speed * delta)
	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, deacceleration * delta)

	velocity_2d *= speed_modifier

	skin.set_move_speed(velocity_2d.length(), run_speed)

	velocity.x = velocity_2d.x
	velocity.z = velocity_2d.y

func ability_logic() -> void:
	# Actual Attack
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			skin.attack()
		else:
			skin.cast_spell()
			stop_movement(0.3, 0.3)
	
	# Defend
	defend = Input.is_action_pressed("block")

	# Switch between weapon and magic
	if Input.is_action_just_pressed('switch weapon') and not skin.is_attacking():
		weapon_active = not weapon_active
		skin.switch_weapon(weapon_active)
		do_squash_and_stretch(0.95, 0.15)

func stop_movement(start_duration: float, end_duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func do_squash_and_stretch(value: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch", value, duration)
	tween.tween_property(skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
