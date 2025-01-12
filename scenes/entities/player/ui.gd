extends Control

@onready var heart_container: HBoxContainer = %HeartContainer
var heart_scene: PackedScene = preload("res://scenes/entities/player/heart.tscn")

func update_health(value: int) -> void:
	var current_hearts: int = heart_container.get_child_count()

	if current_hearts == value:
		return
	elif current_hearts < value:
		for x in range(value - current_hearts):
			var heart = heart_scene.instantiate()
			heart_container.add_child(heart)
			heart.change_alpha(1.0)
			await get_tree().create_timer(0.3).timeout
	elif current_hearts > value:
		for x in range(current_hearts, value, -1):
			var heart = heart_container.get_child(x - 1)
			var tween: Tween = heart.change_alpha(0.0)
			tween.finished.connect(heart.queue_free)
