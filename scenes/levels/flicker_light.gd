@tool
extends OmniLight3D

@export var variation: float = 0.2
@export var base: float = 1.0
@export var animate_every_n_frames: int = 3
var frame: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if frame == 0:
		var sampled_noise: float = base + variation * randf()
		light_energy = sampled_noise
	frame = (frame + 1) % animate_every_n_frames
