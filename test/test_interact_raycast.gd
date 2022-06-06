extends GutTest

const InteractRaycast := preload("res://player/interact_raycast.gd")
const InteractBox := preload("res://player/interact_box.gd")

const TEST_INTERACT_BOX_SCENE := preload("res://map/test_interact-box.tscn")
const INTERACT_RAYCAST_SCENE := preload("res://player/interact_raycast.tscn")


func test_can_interact():
	var interact_raycast := add_child_autofree(InteractRaycast.new()) as InteractRaycast
	watch_signals(interact_raycast)
	var input_sender = InputSender.new(interact_raycast)
	input_sender.action_down(interact_raycast.get_interact_input_action())
	assert_signal_emitted(interact_raycast, "interacted")


func test_can_hover_interactable():
	var interact_raycast: InteractRaycast = add_child_autofree(INTERACT_RAYCAST_SCENE.instance())
	watch_signals(interact_raycast)
	var interact_box: InteractBox = add_child_autofree(TEST_INTERACT_BOX_SCENE.instance())
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)
	assert_signal_emitted_with_parameters(interact_raycast, "interactable_hovered_changed", [true])


func test_can_stop_hovering_interactable():
	# WITH an InteractRaycast that's hovering an InteractBox
	var interact_raycast: InteractRaycast = add_child_autofree(INTERACT_RAYCAST_SCENE.instance())
	watch_signals(interact_raycast)
	var interact_box: InteractBox = add_child_autofree(TEST_INTERACT_BOX_SCENE.instance())
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	# WHEN we rotate to a different direction (e.g.: player turns camera elsewhere)
	# AND we update the Raycast
	interact_raycast.rotate_y(90)
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	# THEN we should stop hovering and emit a signal
	assert_signal_emitted_with_parameters(interact_raycast, "interactable_hovered_changed", [false])


func test_hovering_interactable_connects_interact_signal():
	var interact_raycast: InteractRaycast = add_child_autofree(INTERACT_RAYCAST_SCENE.instance())
	watch_signals(interact_raycast)
	var interact_box: InteractBox = add_child_autofree(TEST_INTERACT_BOX_SCENE.instance())
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)
	assert_connected(interact_raycast, interact_box, "interacted")


func test_unhovering_interactable_disconnects_interact_signal():
	# WITH an InteractRaycast that's hovering an InteractBox
	var interact_raycast: InteractRaycast = add_child_autofree(INTERACT_RAYCAST_SCENE.instance())
	watch_signals(interact_raycast)
	var interact_box: InteractBox = add_child_autofree(TEST_INTERACT_BOX_SCENE.instance())
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	# WHEN we rotate to a different direction (e.g.: player turns camera elsewhere)
	# AND we update the Raycast
	interact_raycast.rotate_y(90)
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	# THEN we should stop hovering and emit a signal
	assert_not_connected(interact_raycast, interact_box, "interacted")


func test_deactivating_interact_box_unhovers():
	var interact_raycast: InteractRaycast = add_child_autofree(INTERACT_RAYCAST_SCENE.instance())
	watch_signals(interact_raycast)
	var interact_box: InteractBox = add_child_autofree(TEST_INTERACT_BOX_SCENE.instance())
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	interact_box.is_active = false
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	assert_signal_emitted_with_parameters(interact_raycast, "interactable_hovered_changed", [false])


func test_activating_interact_box_hovers():
	var interact_raycast: InteractRaycast = add_child_autofree(INTERACT_RAYCAST_SCENE.instance())
	watch_signals(interact_raycast)
	var interact_box: InteractBox = add_child_autofree(TEST_INTERACT_BOX_SCENE.instance())
	interact_box.is_active = false
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	interact_box.is_active = true
	interact_raycast.force_raycast_update()
	simulate(interact_raycast, 1, 1.0)

	assert_signal_emitted_with_parameters(interact_raycast, "interactable_hovered_changed", [true])
