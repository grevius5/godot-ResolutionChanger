tool extends EditorPlugin

# Constant
const CONFIG_PATH = "res://addons/resolutionChanger/Resolutions.txt"

# UI elements
var dock : Control
var custom_resolution : Control

# Resolution data
var resolutions_data : Dictionary = {}
var config  = ConfigFile.new()

# UI elements
var popup : PopupMenu
var menu : MenuButton

# Custom data vars
var custom_sections : MenuButton
var custom_label : LineEdit
var custom_width : SpinBox
var custom_height : SpinBox

func _enter_tree() -> void:
	# Preload needed scenes
	dock = preload("res://addons/resolutionChanger/resolutionMenu.tscn").instance() as Control
	custom_resolution = preload("res://addons/resolutionChanger/AddResolution.tscn").instance() as Control

	# Get all data for custom resolution
	custom_sections = custom_resolution.get_node("WindowDialog/MarginContainer/VerticalContainer/DeviceContainer/Device") as MenuButton
	custom_label = custom_resolution.get_node("WindowDialog/MarginContainer/VerticalContainer/LabelContainer/LineEdit") as LineEdit
	custom_width = custom_resolution.get_node("WindowDialog/MarginContainer/VerticalContainer/WidthContainer/SpinBox") as SpinBox
	custom_height = custom_resolution.get_node("WindowDialog/MarginContainer/VerticalContainer/HeightContainer/SpinBox") as SpinBox

	# Connect device selection button
	custom_sections.get_popup().connect("id_pressed", self, "custom_device_selection")

	# Connect the save and cancel button
	(custom_resolution.get_node("WindowDialog/MarginContainer/VerticalContainer/Buttons/Cancel") as Button).connect("pressed", self, "close_popup")
	(custom_resolution.get_node("WindowDialog/MarginContainer/VerticalContainer/Buttons/Save") as Button).connect("pressed", self, "save_popup")

	# Load config file
	config.load(CONFIG_PATH)

	# Populate all resolution data
	populateResolution()
	popup.connect("id_pressed", self, "switched")

	# Add elements to editor ui
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, dock)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, custom_resolution)

	# Trick to have the popup of right size
	(custom_resolution.get_node("WindowDialog") as WindowDialog).popup_centered()
	(custom_resolution.get_node("WindowDialog") as WindowDialog).hide()

	check_selected_resolution()


# Check if one of the existent resolution were used
func check_selected_resolution() -> void:
	var width : int = ProjectSettings.get("display/window/size/test_width") as int
	var height : int = ProjectSettings.get("display/window/size/test_height") as int

	for i in resolutions_data:
		var res : ResolutionData = resolutions_data[i] as ResolutionData

		# check if resolution are the same
		if res.size.x == width && res.size.y == height:
			menu.text = create_label_name(res.label, res.size)



# Function to clear all existent resolution (used befor reloading)
func clear_resolution() -> void:
	(dock.get_node("Resolutions") as MenuButton).get_popup().clear()
	resolutions_data.clear()


func populateResolution() -> void:
	clear_resolution()

	# Get menu button
	menu = dock.get_node("Resolutions") as MenuButton
	popup = menu.get_popup() as PopupMenu

	var id : int = 0
	for section in config.get_sections():
		# Create section item
		popup.add_separator(section)
		custom_sections.get_popup().add_radio_check_item(section, id)

		id = id + 1

		for label in config.get_section_keys(section):
			# Create resolution item
			var data = ResolutionData.new()
			var resolution : Vector2 = config.get_value(section, label) as Vector2
			data.label = label
			data.size = resolution
			data.id = id

			resolutions_data[id] = data

			popup.add_item(create_label_name(label, resolution), data.id)
			popup.set_item_tooltip(data.id, "Rateo: %.2f" % (resolution.x / resolution.y) )

			id = id + 1

	popup.add_separator("")
	id = id + 1
	# We use id + 1 because separator get one id position
	popup.add_item("Add custom...", id)


func create_label_name(label : String, resolution: Vector2) -> String:
	return (label as String).replace("_", " ") + " (" + str(resolution.x) + "x" + str(resolution.y) + ")"


func save_popup() -> void:
	var section : String = get_selected_device()
	var label : String = custom_label.text.replace(" ", "_")
	var width : int = custom_width.value
	var height : int = custom_height.value

	if label != "":
		config.set_value(section, label, Vector2(width, height))
		config.save(CONFIG_PATH)

		populateResolution()

		close_popup()


func close_popup() -> void:
	(custom_resolution.get_node("WindowDialog") as WindowDialog).hide()


func switched(id : int) -> void:
	var label = menu.get_popup().get_item_text(id)

	# Check for resolution selection or creation
	if label != "Add custom...":
		var data : ResolutionData = resolutions_data[id] as ResolutionData
		menu.text = create_label_name(data.label, data.size)

		ProjectSettings.set("display/window/size/test_width", data.size.x)
		ProjectSettings.set("display/window/size/test_height", data.size.y)
		ProjectSettings.save()
	else:
		# Show custom popup
		deselect_all_devices()

		custom_label.text = ""
		custom_width.value = 1024
		custom_height.value = 768
		custom_device_selection(0)

		var size : Vector2 = (custom_resolution.get_node("WindowDialog/MarginContainer") as MarginContainer).rect_size
		(custom_resolution.get_node("WindowDialog") as WindowDialog).popup_centered_minsize(size)


# Select device from button menu by it's id
func custom_device_selection(id: int) -> void:
	deselect_all_devices()

	# Check the selected one
	var index = custom_sections.get_popup().get_item_index(id)
	custom_sections.get_popup().set_item_checked(index, true)

	custom_sections.text = custom_sections.get_popup().get_item_text(index)


# Get the selected device or "Others" as default
func get_selected_device() -> String:
	# Return the selected device
	for i in custom_sections.get_popup().get_item_count():
		if custom_sections.get_popup().is_item_checked(i):
			return custom_sections.get_popup().get_item_text(i)

	return "Others"


# Function to deselect all devices from the button menu
func deselect_all_devices() -> void:
	# Uncheck all devices
	for i in custom_sections.get_popup().get_item_count():
		custom_sections.get_popup().set_item_checked(i, false)


func _exit_tree() -> void:
	# Remove dock
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, dock)
	dock.queue_free()

	# Remove custom resolution
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, custom_resolution)
	custom_resolution.queue_free()


# Usefull class for resolution data
class ResolutionData:
	var id : int
	var label : String
	var size : Vector2

	func _init() -> void:
		pass