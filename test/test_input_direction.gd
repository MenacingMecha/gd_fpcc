extends GutTest

const InputDirection := preload("res://player/input_direction.gd")

const INPUT_DIRECTION_SCENE := preload("res://player/input_direction.tscn")


func test_can_get_cardinal_look_direction(
	params = use_parameters(
		[
			["look_left", Vector2.LEFT],
			["look_right", Vector2.RIGHT],
			["look_up", Vector2.UP],
			["look_down", Vector2.DOWN]
		]
	)
):
	var input_direction: InputDirection = add_child_autofree(INPUT_DIRECTION_SCENE.instance())
	var input_sender = InputSender.new(input_direction.get_node("LookJoy"))
	input_sender.action_down(params[0])
	assert_eq(input_direction.get_look_direction(), params[1])


func test_can_get_diagonal_look_direction(
	params = use_parameters(
		[
			["look_left", "look_up", Vector2(-1, -1).normalized()],
			["look_right", "look_up", Vector2(1, -1).normalized()],
			["look_right", "look_down", Vector2(1, 1).normalized()],
			["look_left", "look_down", Vector2(-1, 1).normalized()],
		]
	)
):
	var input_direction: InputDirection = add_child_autofree(INPUT_DIRECTION_SCENE.instance())
	var input_sender = InputSender.new(input_direction.get_node("LookJoy"))
	input_sender.action_down(params[0])
	input_sender.action_down(params[1])
	assert_eq(input_direction.get_look_direction(), params[2])


func test_can_get_cardinal_move_direction_with_keyboard(
	params = use_parameters(
		[
			["move_left_k", Vector2.LEFT],
			["move_right_k", Vector2.RIGHT],
			["move_up_k", Vector2.UP],
			["move_down_k", Vector2.DOWN]
		]
	)
):
	var input_direction: InputDirection = add_child_autofree(INPUT_DIRECTION_SCENE.instance())
	var input_sender = InputSender.new(input_direction.get_node("MoveKey"))
	input_sender.action_down(params[0])
	assert_eq(input_direction.get_move_direction(), params[1])



func test_can_get_cardinal_move_direction_with_joypad(
	params = use_parameters(
		[
			["move_left", Vector2.LEFT],
			["move_right", Vector2.RIGHT],
			["move_up", Vector2.UP],
			["move_down", Vector2.DOWN]
		]
	)
):
	var input_direction: InputDirection = add_child_autofree(INPUT_DIRECTION_SCENE.instance())
	var input_sender = InputSender.new(input_direction.get_node("MoveJoy"))
	input_sender.action_down(params[0])
	assert_eq(input_direction.get_move_direction(), params[1])


func test_can_get_diagonal_move_direction_with_keyboard(
	params = use_parameters(
		[
			["move_left_k", "move_up_k", Vector2(-1, -1).normalized()],
			["move_right_k", "move_up_k", Vector2(1, -1).normalized()],
			["move_right_k", "move_down_k", Vector2(1, 1).normalized()],
			["move_left_k", "move_down_k", Vector2(-1, 1).normalized()],
		]
	)
):
	var input_direction: InputDirection = add_child_autofree(INPUT_DIRECTION_SCENE.instance())
	var input_sender = InputSender.new(input_direction.get_node("MoveKey"))
	input_sender.action_down(params[0])
	input_sender.action_down(params[1])
	assert_eq(input_direction.get_move_direction(), params[2])


func test_can_get_diagonal_move_direction_with_joypad(
	params = use_parameters(
		[
			["move_left", "move_up", Vector2(-1, -1).normalized()],
			["move_right", "move_up", Vector2(1, -1).normalized()],
			["move_right", "move_down", Vector2(1, 1).normalized()],
			["move_left", "move_down", Vector2(-1, 1).normalized()],
		]
	)
):
	var input_direction: InputDirection = add_child_autofree(INPUT_DIRECTION_SCENE.instance())
	var input_sender = InputSender.new(input_direction.get_node("MoveJoy"))
	input_sender.action_down(params[0])
	input_sender.action_down(params[1])
	assert_eq(input_direction.get_move_direction(), params[2])


func test_can_hold_both_joypad_and_keyboard_move_directions_without_a_speed_increase(
	params = use_parameters(
		[
			["move_left", "move_left_k", Vector2.LEFT],
			["move_right", "move_right_k", Vector2.RIGHT],
			["move_up", "move_up_k", Vector2.UP],
			["move_down", "move_down_k", Vector2.DOWN]
		]
	)
):
	var input_direction: InputDirection = add_child_autofree(INPUT_DIRECTION_SCENE.instance())
	var input_sender = InputSender.new(input_direction.get_node("MoveJoy"))
	input_sender.add_receiver(input_direction.get_node("MoveKey"))
	input_sender.action_down(params[0])
	input_sender.action_down(params[1])
	assert_eq(input_direction.get_move_direction(), params[2])
