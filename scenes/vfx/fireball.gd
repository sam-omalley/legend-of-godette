extends Area3D

var direction: Vector3
var speed: float = 20.0
var max_distance: float = 40

@onready var decay_timer: Timer = %DecayTimer

func _ready() -> void:
	decay_timer.start(max_distance / speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body:Node3D) -> void:
	if body and "hit" in body:
		body.hit()
	queue_free()


func _on_decay_timer_timeout() -> void:
	queue_free()
