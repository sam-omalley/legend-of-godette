extends Node3D

@onready var raycast := %RayCast3D

var can_damage: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if can_damage:
		var collider: Object = raycast.get_collider()
		if collider and 'hit' in collider:
			collider.hit()
