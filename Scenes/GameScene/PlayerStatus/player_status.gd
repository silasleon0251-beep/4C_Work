extends Control

# 引用UI节点
@onready var eq_bar: ProgressBar = $HBoxContainer/VBoxContainer/HBoxContainer/EQ_Bar
@onready var iq_bar: ProgressBar = $HBoxContainer/VBoxContainer/HBoxContainer2/IQ_Bar
@onready var eq_value: Label = $HBoxContainer/VBoxContainer/HBoxContainer/EQ_value
@onready var iq_value: Label = $HBoxContainer/VBoxContainer/HBoxContainer2/IQ_value


# 游戏中直接修改这两个值即可
var EQ: int = 50:
	set(value):
		EQ = clamp(value, 0, 100)  # 限制0-100
		eq_bar.value = EQ
		eq_value.text = str(EQ)  # 只显示数字

var IQ: int = 50:
	set(value):
		IQ = clamp(value, 0, 100)
		iq_bar.value = IQ
		iq_value.text = str(IQ)  # 只显示数字


# 初始化
func _ready()->void:
	# 设置初始值
	EQ = 50
	IQ = 70
