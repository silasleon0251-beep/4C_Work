# HistoryManager.gd
# 对话历史管理器
# 负责记录和管理游戏中的对话历史记录

extends Node

# 信号：当历史记录更新时发出，传递完整的历史记录数组
signal history_updated(history: Array)

# 存储对话历史记录的数组
# 每个条目是一个字典，包含 speaker（说话者）、text（文本）、timestamp（时间戳）
var _history: Array = []

# 最大历史记录条数限制，防止内存无限增长
var _max_history_size: int = 100


# 节点就绪时执行，设置信号连接
func _ready() -> void:
	print("HistoryManager ready, 连接信号...")
	
	# 连接 DialogueManager 的 got_dialogue 信号
	# 当有新的对话行时触发
	if not DialogueManager.got_dialogue.is_connected(_on_got_dialogue):
		DialogueManager.got_dialogue.connect(_on_got_dialogue)
		print("got_dialogue 信号已连接")
	else:
		print("got_dialogue 信号已经连接")
	
	# 连接 DialogueManager 的 dialogue_ended 信号
	# 当对话结束时触发
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		print("dialogue_ended 信号已连接")
	
	# 注意：以下代码重复了，可能是冗余的
	# 建议删除重复的连接代码
	if not DialogueManager.got_dialogue.is_connected(_on_got_dialogue):
		DialogueManager.got_dialogue.connect(_on_got_dialogue)
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


# 处理新对话行的回调函数
# @param dialogue_line: DialogueLine - 对话行对象，包含角色、文本等信息
func _on_got_dialogue(dialogue_line: DialogueLine) -> void:
	#print("HistoryManager: 捕获对话: ", dialogue_line.character, ": ", dialogue_line.text)
	
	# 创建历史记录条目
	var entry: Dictionary = {
		"speaker": dialogue_line.character.replace(":", "").strip_edges(),      # 说话者名称
		"text": dialogue_line.text,              # 对话文本内容
		"timestamp": Time.get_ticks_msec()       # 时间戳（毫秒）
	}
	#print(entry.speaker," ", entry.text)
	# 将新条目添加到历史记录末尾
	_history.append(entry)
	
	# 如果超过最大容量，从头部移除最旧的条目
	while _history.size() > _max_history_size:
		_history.pop_front()
	
	# 发出信号通知历史记录已更新
	history_updated.emit(_history)


# 处理对话结束的回调函数
# @param _resource: DialogueResource - 对话资源
#（未使用）备选方案
func _on_dialogue_ended(_resource: DialogueResource) -> void:
	# 创建分隔符条目，用于在对话记录中标记对话结束
	var separator: Dictionary = {
		"speaker": "---",                        # 特殊标识表示分隔符
		"text": "对话结束 ---",                  # 分隔符文本
		"timestamp": Time.get_ticks_msec()       # 时间戳
	}
	
	# 添加分隔符到历史记录
	_history.append(separator)
	
	# 发出信号通知历史记录已更新
	history_updated.emit(_history)


# 获取当前历史记录的副本
# @return Array - 历史记录数组的副本（避免外部修改）
func get_history() -> Array:
	return _history.duplicate()


# 清空所有历史记录
func clear_history() -> void:
	_history.clear()                            # 清空数组
	history_updated.emit(_history)              # 发出更新信号


# 设置最大历史记录容量
# @param size: int - 新的最大容量（至少为1）
func set_max_history_size(size: int) -> void:
	# 确保最大容量至少为1
	_max_history_size = max(1, int(size))
	
	# 如果当前记录数超过新容量，移除多余的旧记录
	while _history.size() > _max_history_size:
		_history.pop_front()
	
	# 发出信号通知历史记录已更新
	history_updated.emit(_history)
