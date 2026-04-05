extends Control

# 引用UI节点

@onready var player_status_ui: Control = $"."

@onready var eq_bar: ProgressBar = $HBoxContainer/VBoxContainer/HBoxContainer/EQ_Bar
@onready var iq_bar: ProgressBar = $HBoxContainer/VBoxContainer/HBoxContainer2/IQ_Bar
@onready var luck_bar: ProgressBar = $HBoxContainer/VBoxContainer/HBoxContainer3/Luck_Bar

@onready var eq_value: Label = $HBoxContainer/VBoxContainer/HBoxContainer/EQ_Bar/EQ_value
@onready var iq_value: Label = $HBoxContainer/VBoxContainer/HBoxContainer2/IQ_Bar/IQ_value
@onready var luck_value: Label = $HBoxContainer/VBoxContainer/HBoxContainer3/Luck_Bar/Luck_value

# 动画时长（秒）
const ANIM_DURATION: float = 0.2

# 游戏中直接修改这两个值即可
var EQ: int = GlobalConfig.EQ:
	set(value):
		EQ = clamp(value, 0, 100)  # 限制0-100
		eq_bar.value = EQ
		eq_value.text = str(EQ)  # 只显示数字

var IQ: int = GlobalConfig.IQ:
	set(value):
		IQ = clamp(value, 0, 100)
		iq_bar.value = IQ
		iq_value.text = str(IQ)  # 只显示数字

var Luck: int = GlobalConfig.Luck:
	set(value):
		Luck = clamp(value, 0, 100)
		luck_bar.value = Luck
		luck_value.text = str(Luck)  # 只显示数字

# 初始化
func _ready()->void:
	# 设置初始值
	EQ = GlobalConfig.EQ
	IQ = GlobalConfig.IQ
	Luck = GlobalConfig.Luck
	
	# 关联信号
	SignalManager.show_player_status_UI.connect(_show_player_status_UI)
	SignalManager.hide_player_status_UI.connect(_hide_player_status_UI)
	SignalManager.update_player_status_UI.connect(_update_player_status_UI)


# 测试节点
#func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("增加"):
		##GlobalConfig.IQ += 1
		##_update_player_status_UI()
		#SignalManager.show_player_status_UI.emit()
#
	#if Input.is_action_just_pressed("减少"):
		##GlobalConfig.IQ -= 1
		##_update_player_status_UI()
		#SignalManager.hide_player_status_UI.emit()

# 显示节点
func _show_player_status_UI()->void:
	_update_player_status_UI()
	player_status_ui.visible = true
	# 淡入
	var tween:Tween = create_tween()
	tween.tween_property(player_status_ui, "modulate:a", 1.0, ANIM_DURATION)

# 隐藏节点
func _hide_player_status_UI()->void:
	_update_player_status_UI()
	# 先淡出，结束后再设 invisible
	var tween:Tween = create_tween()
	tween.tween_property(player_status_ui, "modulate:a", 0.0, ANIM_DURATION)
	tween.finished.connect(func()->void:
		player_status_ui.visible = false
	)

# 更新数值
func _update_player_status_UI()->void:
	# 全局数据会改变,给脚本的成员属性赋值就能更新
	EQ = GlobalConfig.EQ
	IQ = GlobalConfig.IQ
	Luck = GlobalConfig.Luck
