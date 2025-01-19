extends AnimationTree

var attack_animation: int = 1
var weapon_active: bool = true
var current_spell: GameStateManager.Spells = GameStateManager.Spells.FIREBALL

func set_attack_animation(value: int) -> void:
	attack_animation = value

func set_weapon_active(value: bool) -> void:
	weapon_active = value

func set_current_spell(value: GameStateManager.Spells) -> void:
	current_spell = value