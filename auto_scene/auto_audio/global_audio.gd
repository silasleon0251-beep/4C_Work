extends Node

static var instance: GlobalAudio

# 检查器拖入音效
@export var sound_click: AudioStream
@export var sound_hover: AudioStream
@export var sound_confirm: AudioStream
@export var bgm_main: AudioStream

# 音频播放器
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

# ------------------------------
# 你的音量公式（只复制这两个函数）
# ------------------------------
func get_log_volume(linear_val: int) -> int:
	var val = clamp(linear_val, 0, 100)
	if val == 0:
		return 0
	var log_val = 100.0 * (pow(10.0, val / 50.0) - 1.0) / 200.0
	return round(log_val) as int

func get_final_volume(master: int, vol: int) -> int:
	var master_log = get_log_volume(master)
	var vol_log = get_log_volume(vol)
	var final = (master_log * vol_log) / 100.0
	return clamp(final, 0, 100) as int

# ------------------------------
# 应用音量（只读 GlobalConfig）
# ------------------------------
func apply_volume():
	if not GlobalConfig:
		return

	# BGM 音量
	var bgm_final = get_final_volume(GlobalConfig.main_volume_value, GlobalConfig.bgm_value)
	bgm_player.volume_db = linear_to_db(bgm_final / 100.0) if bgm_final != 0 else -80.0

	# 音效音量
	var sfx_final = get_final_volume(GlobalConfig.main_volume_value, GlobalConfig.sound_effect_value)
	sfx_player.volume_db = linear_to_db(sfx_final / 100.0) if sfx_final != 0 else -80.0

# ------------------------------
# 初始化
# ------------------------------
func _ready():
	if instance:
		queue_free()
		return
	instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	apply_volume()

# ------------------------------
# 播放音效
# ------------------------------
static func play_click():
	if not instance or not instance.sound_click: return
	instance.apply_volume()
	instance.sfx_player.stream = instance.sound_click
	instance.sfx_player.play()

static func play_hover():
	if not instance or not instance.sound_hover: return
	instance.apply_volume()
	instance.sfx_player.stream = instance.sound_hover
	instance.sfx_player.play()

static func play_confirm():
	if not instance or not instance.sound_confirm: return
	instance.apply_volume()
	instance.sfx_player.stream = instance.sound_confirm
	instance.sfx_player.play()

# ------------------------------
# BGM
# ------------------------------
static func play_main_bgm(loop: bool = true):
	if not instance or not instance.bgm_main: return
	instance.apply_volume()
	instance.bgm_player.stream = instance.bgm_main
	instance.bgm_player.loop = loop
	instance.bgm_player.play()

static func stop_bgm():
	if instance:
		instance.bgm_player.stop()
