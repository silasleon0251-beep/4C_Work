@icon("./assets/responses_menu.svg")

## A [Container] for dialogue responses provided by [b]Dialogue Manager[/b].
## 一个用于承载 [b]对话管理器[/b] 提供的对话选项的 [容器] 控件。
class_name DialogueResponsesMenu extends Container


## Emitted when a response is focused.
## 当某个对话选项获得焦点时发出此信号。
signal response_focused(response: Control)

## Emitted when a response is selected.
## 当某个对话选项被选中时发出此信号。
signal response_selected(response: Control)


## Optionally specify a control to duplicate for each response
## 可选参数：指定用于为每个对话选项复制的控件模板
@export var response_template: Control

## The action for accepting a response (is possibly overridden by parent dialogue balloon).
## 确认选择对话选项的操作名称（可能会被父级对话气泡覆盖）。
@export var next_action: StringName = &""

## Automatically set up focus neighbours when the responses list changes.
## 当对话选项列表发生变化时，自动配置焦点邻居。
@export var auto_configure_focus: bool = true

## Automatically focus the first item when showing.
## 显示时自动将焦点设置到第一个选项上。
@export var auto_focus_first_item: bool = true

## Hide any responses where [code]is_allowed[/code] is false
## 隐藏所有 [code]is_allowed[/code] 为 false 的对话选项
@export var hide_failed_responses: bool = false

## The list of dialogue responses.
## 对话选项列表。
var responses: Array = []:
	set(value):
		responses = value
		_apply_responses()
	get:
		return responses

# The previously focused item in this menu.
# 此菜单中上一个获得焦点的选项。
var _previously_focused_item: Control = null


func _ready() -> void:
	visibility_changed.connect(func():
		if auto_focus_first_item and visible and get_menu_items().size() > 0:
			var first_item: Control = get_menu_items()[0]
			if first_item.is_inside_tree():
				first_item.grab_focus()
	)

	if is_instance_valid(response_template):
		response_template.hide()

	get_viewport().gui_focus_changed.connect(_on_focus_changed)


## Get the selectable items in the menu.
## 获取菜单中的可选择项。
func get_menu_items() -> Array:
	var items: Array = []
	for child in get_children():
		if not child.visible: continue
		if "Disallowed" in child.name: continue
		items.append(child)

	return items


## Prepare the menu for keyboard and mouse navigation.
## 为菜单配置键盘和鼠标导航功能。
func configure_focus() -> void:
	var items = get_menu_items()
	for i in items.size():
		var item: Control = items[i]

		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()

		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_neighbor_left = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_neighbor_left = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()

		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_neighbor_right = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_neighbor_right = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()

		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.gui_input.connect(_on_response_gui_input.bind(item, item.get_meta("response")))

	_previously_focused_item = items[0]

	if auto_focus_first_item:
		items[0].grab_focus()


#region Internal
# 内部逻辑区域

# Set up the visual side of things.
# 配置视觉相关的内容。
func _apply_responses() -> void:
	# Remove any current items
	# 移除所有现有选项
	for item in get_children():
		if item == response_template: continue

		remove_child(item)
		item.queue_free()

	# Add new items
	# 添加新选项
	if responses.size() > 0:
		for response in responses:
			if hide_failed_responses and not response.is_allowed: continue

			var item: Control
			if is_instance_valid(response_template):
				item = response_template.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
				item.show()
			else:
				item = Button.new()
			item.name = "Response%d" % get_child_count()
			if not response.is_allowed:
				item.name = item.name + &"Disallowed"
				item.disabled = true

			# If the item has a response property then use that
			# 如果控件有 response 属性，则直接赋值
			if "response" in item:
				item.response = response
			# Otherwise assume we can just set the text
			# 否则默认设置控件的文本属性
			else:
				item.text = response.text

			item.set_meta("response", response)

			add_child(item)

		if auto_configure_focus:
			configure_focus()


#endregion

#region Signals
# 信号处理区域

func _on_focus_changed(control: Control) -> void:
	if "Disallowed" in control.name: return
	if not control in get_menu_items(): return

	if _previously_focused_item != control:
		_previously_focused_item = control
		response_focused.emit(control)


func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return

	item.grab_focus()


func _on_response_gui_input(event: InputEvent, item: Control, response) -> void:
	if "Disallowed" in item.name: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		response_selected.emit(response)
	elif event.is_action_pressed(&"ui_accept" if next_action.is_empty() else next_action) and item in get_menu_items():
		get_viewport().set_input_as_handled()
		response_selected.emit(response)


#endregion
