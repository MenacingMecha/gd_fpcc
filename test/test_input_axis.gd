extends GutTest

const InputAxis := preload("res://player/input_axis.gd")


func test_can_input_cardinal_directions(
	params = use_parameters(
		[
			["ui_left", Vector2.LEFT],
			["ui_right", Vector2.RIGHT],
			["ui_up", Vector2.UP],
			["ui_down", Vector2.DOWN]
		]
	)
):
	var input_axis: InputAxis = add_child_autofree(InputAxis.new())
	var input_sender = InputSender.new(input_axis)
	input_sender.action_down(params[0])
	assert_eq(input_axis.get_raw_direction(), params[1])


func test_can_input_diagonal_directions(
	params = use_parameters(
		[
			["ui_left", "ui_up", Vector2(-1, -1)],
			["ui_right", "ui_up", Vector2(1, -1)],
			["ui_right", "ui_down", Vector2(1, 1)],
			["ui_left", "ui_down", Vector2(-1, 1)],
		]
	)
):
	var input_axis: InputAxis = add_child_autofree(InputAxis.new())
	var input_sender = InputSender.new(input_axis)
	input_sender.action_down(params[0])
	input_sender.action_down(params[1])
	assert_eq(input_axis.get_raw_direction(), params[2])


func test_releasing_input_direction(
	params = use_parameters(
		[
			["ui_left", "ui_up"],
			["ui_right", "ui_up"],
			["ui_right", "ui_down"],
			["ui_left", "ui_down"],
		]
	)
):
	var input_axis: InputAxis = add_child_autofree(InputAxis.new())
	var input_sender = InputSender.new(input_axis)
	input_sender.action_up(params[0], 0)
	input_sender.action_up(params[1], 0)
	assert_eq(input_axis.get_raw_direction(), Vector2.ZERO)
