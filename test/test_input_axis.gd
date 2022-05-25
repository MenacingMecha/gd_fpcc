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


func test_can_fake_get_raw_direction():
	var input_axis: InputAxis = add_child_autofree(InputAxis.new())
	var direction := Vector2(1, 1)
	input_axis.fake_direction = direction
	assert_eq(input_axis.get_raw_direction(), direction)


func test_fake_direction_cannot_exceed_real_direction():
	var input_axis: InputAxis = add_child_autofree(InputAxis.new())
	var direction := Vector2(2, 2)
	input_axis.fake_direction = direction
	assert_eq(input_axis.get_raw_direction(), Vector2(1, 1))


func test_can_null_fake_direction_after_setting():
	var input_axis: InputAxis = add_child_autofree(InputAxis.new())
	input_axis.fake_direction = Vector2.RIGHT
	input_axis.fake_direction = null
	assert_null(input_axis.fake_direction)
