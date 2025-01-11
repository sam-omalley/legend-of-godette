class_name SignalConnector
extends Node

@export var container: Node
@export var handler: Node
@export var slot_name: String
@export var signal_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if slot_name not in handler:
		push_error("%s not function of %s" % [slot_name, handler.name])
	var callable := Callable(handler, slot_name)

	for child in container.get_children():
		if child.has_signal(signal_name):
			child.connect(signal_name, callable)
