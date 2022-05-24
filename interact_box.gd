extends Area

signal interacted_with

const COLLISION_LAYER_BIT := 0b10

export var is_active := true setget set_is_active
export var _one_shot := false


func _on_ready():
	# call setter on ready (doesn't seem to work in a `tool` script)
	self.is_active = self.is_active


func on_interacted_with():
	# print("[DEBUG] %s HAS BEEN INTERACTED WITH" % name)
	emit_signal("interacted_with")

	if self._one_shot:
		self.is_active = false


func set_is_active(new_active: bool):
	is_active = new_active
	collision_layer = COLLISION_LAYER_BIT if new_active else 0
