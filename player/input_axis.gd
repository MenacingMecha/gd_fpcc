extends Node
# Updates input axis directions based on input actions

export var _up_action := "ui_up"
export var _down_action := "ui_down"
export var _left_action := "ui_left"
export var _right_action := "ui_right"

var _up := 0.0
var _down := 0.0
var _left := 0.0
var _right := 0.0


func _unhandled_input(event: InputEvent):
	if event.is_action_type():
		if event.is_action(self._up_action):
			self._up = event.get_action_strength(self._up_action)
		if event.is_action(self._down_action):
			self._down = event.get_action_strength(self._down_action)
		if event.is_action(self._left_action):
			self._left = event.get_action_strength(self._left_action)
		if event.is_action(self._right_action):
			self._right = event.get_action_strength(self._right_action)


func get_raw_direction() -> Vector2:
	return Vector2(self._right - self._left, self._down - self._up)
