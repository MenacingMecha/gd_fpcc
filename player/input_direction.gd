extends Node
# Returns move and look directions based on input axes

const InputAxis := preload("input_axis.gd")

onready var _axis_move_joy := $MoveJoy as InputAxis
onready var _axis_move_key := $MoveKey as InputAxis
onready var _axis_look_joy := $LookJoy as InputAxis


func get_look_direction() -> Vector2:
	return self._axis_look_joy.get_raw_direction().normalized()


func get_move_direction() -> Vector2:
	return (self._axis_move_key.get_raw_direction() + self._axis_move_joy.get_raw_direction()).normalized()
