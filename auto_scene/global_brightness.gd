extends ColorRect

# 全局单例，让任何脚本都能访问
func _ready():
	# 强制永远置顶
	z_index = 999
	show_behind_parent = true
	# 初始透明
	modulate.a = 0

# 调节亮度 0.0~1.0
func set_brightness(value: float):
	value = clamp(value, 0.2, 1.0)
	modulate.a = 1.0 - value
