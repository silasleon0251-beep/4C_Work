extends Node

#游戏是否暂停
var is_game_running : bool


func _ready() -> void:
	is_game_running = true
	_init_select_level()
	# 链接选关信号
	SignalManager.change_level.connect(_receipt_signal)

func _receipt_signal(lv_num:int)->void:
	print("收到选关信号!")
	print("选中: %d"%[lv_num])
	_select_level(lv_num)

# 更新选关数组
func _select_level(lv_num:int)->void:
	_init_select_level()
	if lv_num > 0 && lv_num < 6:
		GlobalData.change_lv[lv_num] = true
	else:
		print("关卡数据错误!")
	
# 初始化选关数组
func _init_select_level()->void:
	GlobalData.change_lv.resize(6)
	GlobalData.change_lv.fill(false)
	print("初始化成功!")
