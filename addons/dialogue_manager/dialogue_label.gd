@icon("./assets/icon.svg")

@tool

## A RichTextLabel specifically for use with [b]Dialogue Manager[/b] dialogue.
## 一个专门用于 [b]对话管理器[/b] 对话的富文本标签。
class_name DialogueLabel extends RichTextLabel


## Emitted for each letter typed out.
## 每打出一个字符时发出此信号。
signal spoke(letter: String, letter_index: int, speed: float)

## Emitted when the player skips the typing of dialogue.
## 当玩家跳过对话打字动画时发出此信号。
signal skipped_typing()

## Emitted when typing starts
## 开始打字时发出此信号。
signal started_typing()

## Emitted when typing finishes.
## 打字完成时发出此信号。
signal finished_typing()

## [Deprecated] No longer emitted.
## [已废弃] 不再发出此信号。
signal paused_typing(duration: float)


## The action to press to skip typing.
## 用于跳过打字动画的操作名称。
@export var skip_action: StringName = &"ui_cancel"

## The speed with which the text types out.
## 文本逐字打出的速度（秒/字符）。
@export var seconds_per_step: float = 0.02

## Automatically have a brief pause when these characters are encountered.
## 遇到这些字符时自动短暂停顿。
@export var pause_at_characters: String = ".?!"

## Don't auto pause if the character after the pause is one of these.
## 如果停顿字符后的下一个字符是以下字符之一，则不自动停顿。
@export var skip_pause_at_character_if_followed_by: String = ")\""

## Don't auto pause after these abbreviations (only if "." is in `pause_at_characters`).[br]
## Abbreviations are limitted to 5 characters in length [br]
## Does not support multi-period abbreviations (ex. "p.m.")
## 在这些缩写后不自动停顿（仅当 "." 包含在 `pause_at_characters` 中时生效）。[br]
## 缩写长度限制为 5 个字符 [br]
## 不支持多句点缩写（例如 "p.m."）
@export var skip_pause_at_abbreviations: PackedStringArray = ["Mr", "Mrs", "Ms", "Dr", "etc", "eg", "ex"]

## The amount of time to pause when exposing a character present in `pause_at_characters`.
## 遇到 `pause_at_characters` 中的字符时的停顿时长。
@export var seconds_per_pause_step: float = 0.3

var _already_mutated_indices: PackedInt32Array = []


## The current line of dialogue.
## 当前的对话文本行。
var dialogue_line:
	set(value):
		if value != dialogue_line:
			dialogue_line = value
			_update_text()
	get:
		return dialogue_line

## Whether the label is currently typing itself out.
## 标签当前是否正在逐字打出文本。
var is_typing: bool = false:
	set(value):
		var is_finished: bool = _is_typing != value and value == false and visible_characters == get_total_character_count()
		_is_typing = value
		if is_finished:
			finished_typing.emit()
	get:
		return _is_typing and not _is_awaiting_mutation
var _is_typing: bool = false

var _last_wait_index: int = -1
var _last_mutation_index: int = -1
var _waiting_seconds: float = 0
var _is_awaiting_mutation: bool = false


func _process(delta: float) -> void:
	if _is_typing:
		# Type out text
		# 逐字打出文本
		if visible_ratio < 1:
			# See if we are waiting
			# 检查是否处于等待状态
			if _waiting_seconds > 0:
				_waiting_seconds = _waiting_seconds - delta
			# If we are no longer waiting then keep typing
			# 如果等待结束则继续打字
			if _waiting_seconds <= 0:
				_type_next(delta, _waiting_seconds)
		else:
			# Make sure any mutations at the end of the line get run
			# 确保行尾的所有内联修改都被执行
			_mutate_inline_mutations(get_total_character_count())
			is_typing = false


## Sets the label's text from the current dialogue line. Override if you want
## to do something more interesting in your subclass.
## 从当前对话文本行设置标签的文本。如果需要在子类中实现更复杂的逻辑，可以重写此方法。
func _update_text() -> void:
	text = dialogue_line.text


## Start typing out the text
## 开始逐字打出文本
func type_out() -> void:
	_update_text()
	visible_characters = 0
	visible_ratio = 0
	_waiting_seconds = 0
	_last_wait_index = -1
	_last_mutation_index = -1
	_already_mutated_indices.clear()

	is_typing = true
	started_typing.emit()

	# Allow typing listeners a chance to connect
	# 给打字事件监听器留出连接的时间
	await get_tree().process_frame

	if get_total_character_count() == 0:
		is_typing = false
	elif seconds_per_step == 0:
		_mutate_remaining_mutations()
		visible_characters = get_total_character_count()
		is_typing = false


## Stop typing out the text and jump right to the end
## 停止逐字打字并直接显示全部文本
func skip_typing() -> void:
	_mutate_remaining_mutations()
	visible_characters = get_total_character_count()
	is_typing = false
	skipped_typing.emit()


# Type out the next character(s)
# 打出下一个（些）字符
func _type_next(delta: float, seconds_needed: float) -> void:
	if _is_awaiting_mutation: return

	if visible_characters == get_total_character_count():
		return

	if _last_mutation_index != visible_characters:
		_last_mutation_index = visible_characters
		_mutate_inline_mutations(visible_characters)
		if _is_awaiting_mutation: return

	# Pause on characters like "."
	# 在 "." 等字符处停顿
	var waiting_seconds: float = seconds_per_pause_step if _should_auto_pause() else 0
	if _last_wait_index != visible_characters and waiting_seconds > 0:
		_last_wait_index = visible_characters
		_waiting_seconds += waiting_seconds
	else:
		visible_characters += 1
		if visible_characters <= get_total_character_count():
			spoke.emit(get_parsed_text()[visible_characters - 1], visible_characters - 1, _get_speed(visible_characters))
		# See if there's time to type out some more in this frame
		# 检查当前帧是否还有时间打出更多字符
		seconds_needed += seconds_per_step * (1.0 / _get_speed(visible_characters))
		if seconds_needed > delta:
			_waiting_seconds += seconds_needed
		else:
			_type_next(delta, seconds_needed)


# Get the speed for the current typing position
# 获取当前打字位置的速度
func _get_speed(at_index: int) -> float:
	var speed: float = 1
	for index in dialogue_line.speeds:
		if index > at_index:
			return speed
		speed = dialogue_line.speeds[index]
	return speed


# Run any inline mutations that haven't been run yet
# 执行所有尚未执行的内联修改
func _mutate_remaining_mutations() -> void:
	for i in range(visible_characters, get_total_character_count() + 1):
		_mutate_inline_mutations(i)


# Run any mutations at the current typing position
# 执行当前打字位置的所有内联修改
func _mutate_inline_mutations(index: int) -> void:
	for inline_mutation in dialogue_line.inline_mutations:
		# inline mutations are an array of arrays in the form of [character index, resolvable function]
		# 内联修改是一个二维数组，格式为 [字符索引, 可解析的函数]
		if inline_mutation[0] > index:
			return
		if inline_mutation[0] == index and not _already_mutated_indices.has(index):
			_is_awaiting_mutation = true
			# The DialogueManager can't be referenced directly here so we need to get it by its path
			# 此处无法直接引用 DialogueManager，因此需要通过路径获取
			await Engine.get_singleton("DialogueManager")._mutate(inline_mutation[1], dialogue_line.extra_game_states, true)
			_is_awaiting_mutation = false

	_already_mutated_indices.append(index)


# Determine if the current autopause character at the cursor should qualify to pause typing.
# 判断光标位置的当前自动停顿字符是否应该触发打字停顿
func _should_auto_pause() -> bool:
	if visible_characters == 0: return false

	var parsed_text: String = get_parsed_text()

	# Avoid outofbounds when the label auto-translates and the text changes to one shorter while typing out
	# Note: visible characters can be larger than parsed_text after a translation event
	# 避免标签自动翻译且打字过程中文本变短导致的数组越界
	# 注意：翻译后可见字符数可能大于解析后的文本长度
	if visible_characters >= parsed_text.length(): return false

	# Ignore pause characters if they are next to a non-pause character
	# 如果停顿字符后紧跟非停顿字符，则忽略该停顿字符
	if parsed_text[visible_characters] in skip_pause_at_character_if_followed_by.split():
		return false

	# Ignore "." if it's between two numbers
	# 如果 "." 出现在两个数字之间则忽略
	if visible_characters > 3 and parsed_text[visible_characters - 1] == ".":
		var possible_number: String = parsed_text.substr(visible_characters - 2, 3)
		if str(float(possible_number)).pad_decimals(1) == possible_number:
			return false

	# Ignore "." if it's used in an abbreviation
	# Note: does NOT support multi-period abbreviations (ex. p.m.)
	# 如果 "." 用于缩写中则忽略
	# 注意：不支持多句点缩写（例如 p.m.）
	if "." in pause_at_characters and parsed_text[visible_characters - 1] == ".":
		for abbreviation in skip_pause_at_abbreviations:
			if visible_characters >= abbreviation.length():
				var previous_characters: String = parsed_text.substr(visible_characters - abbreviation.length() - 1, abbreviation.length())
				if previous_characters == abbreviation:
					return false

	# Ignore two non-"." characters next to each other
	# 忽略两个相邻的非 "." 停顿字符
	var other_pause_characters: PackedStringArray = pause_at_characters.replace(".", "").split()
	if visible_characters > 1 and parsed_text[visible_characters - 1] in other_pause_characters and parsed_text[visible_characters] in other_pause_characters:
		return false

	return parsed_text[visible_characters - 1] in pause_at_characters.split()
