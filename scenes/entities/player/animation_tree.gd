extends AnimationTree

var attack_animation: int = 1
var weapon_active: bool = true

func set_attack_animation(value: int) -> void:
	attack_animation = value

func set_weapon_active(value: bool) -> void:
	weapon_active = value