extends Control

@onready var heart_container: HBoxContainer = %HeartContainer
@onready var spell_texture: TextureRect = %SpellTexture
@onready var energy_bar: TextureProgressBar = %EnergyBar

var heart_scene: PackedScene = preload("res://scenes/entities/player/heart.tscn")
var fire_texture := preload("res://graphics/ui/fire.png")
var heal_texture := preload("res://graphics/ui/heal.png")

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

func update_spell(spell: int) -> void:
	match spell:
		GameStateManager.Spells.FIREBALL:
			spell_texture.texture = fire_texture
		GameStateManager.Spells.HEAL:
			spell_texture.texture = heal_texture

func update_energy(value: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(energy_bar, 'value', value, 0.5)
