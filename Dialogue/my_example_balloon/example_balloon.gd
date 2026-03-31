class_name  MyGame_DialogueManagerExampleBalloon extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.
## 一个用于对话管理器（Dialogue Manager）的基础对话气泡控件。


## The dialogue resource
## 对话资源
@export var dialogue_resource: DialogueResource

## Start from a given title when using balloon as a [Node] in a scene.
## 当在场景中将此气泡作为 [节点] 使用时，从指定的标题开始对话。
@export var start_from_title: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
## 若作为场景中的 [节点] 运行，则自动启动对话。
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
## 显示对话时是否屏蔽所有其他输入。
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
## 用于推进对话的操作名称
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
## 用于跳过对话打字动画的操作名称
@export var skip_action: StringName = &"ui_cancel"

## A sound player for voice lines (if they exist).
## 用于播放语音台词的音频播放器（如果有语音的话）。
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## Temporary game states
## 临时游戏状态
var temporary_game_states: Array = []

## See if we are waiting for the player
## 标记是否正在等待玩家输入
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
## 标记是否正在执行耗时的内联修改，需要隐藏对话气泡
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
## 用于存储临时变量的字典
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current line
## 当前的对话行
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			# 对话已结束，关闭对话气泡
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
## 遇到内联修改时，用于延迟隐藏气泡的冷却计时器。
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
## 对话气泡的基础锚点控件
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
## 显示当前说话角色名称的标签
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
## 显示当前对话内容的标签
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
## 对话选项菜单
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Indicator to show that player can progress dialogue.
## 用于提示玩家可以推进对话的指示器
@onready var progress: Polygon2D = %Progress

#定义一个信号,在加入节点树的时候将自己发送出去
signal dialogue_manager_ready(manager: MyGame_DialogueManagerExampleBalloon)

func _ready() -> void:
	
	dialogue_manager_ready.emit(self) #把自己发出去
	
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	# 如果对话选项菜单未设置推进操作，则使用当前控件的推进操作
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()


func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not dialogue_line.has_tag("voice")


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	# 对话气泡显示期间，仅允许气泡自身处理输入
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	## 检测语言环境变化，并更新当前对话行以显示新语言
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		dialogue_line = await dialogue_resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
## 启动对话
func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not title.is_empty():
		start_from_title = title
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_title, temporary_game_states)
	show()


## Apply any changes to the balloon given a new [DialogueLine].
## 根据新的 [对话行] 应用所有对话气泡的变更。
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	# 显示对话气泡
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for next line
	# 等待下一行对话
	if dialogue_line.has_tag("voice"):
		audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"))
		audio_stream_player.play()
		await audio_stream_player.finished
		next(dialogue_line.next_id)
	elif dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Go to the next line
## 跳转到下一行对话
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals
# 信号处理区域

func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	# 检查是否需要跳过对话打字动画
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	# 当没有对话选项时，气泡自身作为可点击的交互对象
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


#endregion
