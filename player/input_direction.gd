# Returns input direction vectors based on `Input.get_vector()`
# TODO: extend Node and have this be where we do input?
# TODO: after converting to node, assert that all the input mappings exist

enum DirectionTypes { MOVE, LOOK, KEYBOARD }

const UP_DIRECTION_FORMAT_BASE := "%s_up%s"
const DOWN_DIRECTION_FORMAT_BASE := "%s_down%s"
const LEFT_DIRECTION_FORMAT_BASE := "%s_left%s"
const RIGHT_DIRECTION_FORMAT_BASE := "%s_right%s"
const MOVE_PREFIX := "move"
const LOOK_PREFIX := "look"
const KEYBOARD_MODIFIER_SUFFIX := "_k"
const DIRECTION_FORMAT_VALUES_MAP := {
	DirectionTypes.MOVE: [MOVE_PREFIX, ""],
	DirectionTypes.LOOK: [LOOK_PREFIX, ""],
	DirectionTypes.KEYBOARD: [MOVE_PREFIX, KEYBOARD_MODIFIER_SUFFIX]
}

const REVERSE_MOVEMENT_DIRECTION_MULTIPLIER := Vector2(1, -1)  # -z forward
const MIN_DEADZONE := 0.1  # TODO: is this needed? seems duplicated


# Returns the direction for a given `DirectionTypes` axis.
# Use `get_movement_direction()` instead for getting a direction for walking.
static func get_input_direction(direction_type: int) -> Vector2:
	var format_values: Array = DIRECTION_FORMAT_VALUES_MAP[direction_type]
	# TODO: change this not to use Input singleton, as it's a lot harder to test
	return Input.get_vector(
		LEFT_DIRECTION_FORMAT_BASE % format_values,
		RIGHT_DIRECTION_FORMAT_BASE % format_values,
		UP_DIRECTION_FORMAT_BASE % format_values,
		DOWN_DIRECTION_FORMAT_BASE % format_values
	)


# Returns the input axis for movement
# Appends keyboard axis seperately (see: https://github.com/godotengine/godot/issues/45628)
static func get_movement_direction() -> Vector2:
	var keyboard_direction := get_input_direction(DirectionTypes.KEYBOARD)
	var pad_direction := get_input_direction(DirectionTypes.MOVE)
	var accumalated_direction := (pad_direction + keyboard_direction).normalized()
	return accumalated_direction * REVERSE_MOVEMENT_DIRECTION_MULTIPLIER
