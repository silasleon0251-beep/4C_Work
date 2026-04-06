extends Node

# 三个音效：选择、悬停、取消
# ------------------------------
@export var audio_select: AudioStream   # 选择
@export var audio_hover: AudioStream     # 悬停
@export var audio_cancel: AudioStream    # 取消

var bgm_dict: Dictionary = {
	"目录":"res://resource/sound_effect/目录.mp3"
}

@export var test_sound: AudioStream # 测试音效

@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var test_player: AudioStreamPlayer = $TestPlayer

var bgm_timer: Timer = null

func _ready()->void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().process_frame
	
	# 创建BGM定时停止计时器
	bgm_timer = Timer.new()
	add_child(bgm_timer)
	bgm_timer.timeout.connect(stop_bgm)
	
	refresh_volume()


func get_log_volume(linear_val: int) -> float:
	var val:int = clamp(linear_val, 0, 100)
	if val == 0:
		return 0.0
	var log_val:float = 100.0 * (pow(2.0, val / 50.0) - 1.0)
	return log_val

func get_final_volume(master: int, vol: int) -> float:
	var master_log:float = get_log_volume(master)
	var vol_log:float = get_log_volume(vol)
	var final:float = (master_log * vol_log) / 10000.0 * 100.0
	return clamp(final, 0, 100)

# ==============================
# 全局刷新音量（只读）
# ==============================
func refresh_volume()->void:
	_apply_volume()

func _apply_volume()->void:
	if not GlobalConfig: return
	
	var main:int  = GlobalConfig.main_volume_value
	var bgm:int = GlobalConfig.bgm_value
	var sfx:int = GlobalConfig.sound_effect_value
	
	print("main:",main," bgm:", bgm," sfx:", sfx)

	var final_bgm:float = get_final_volume(main, bgm)
	var final_sfx:float = get_final_volume(main, sfx)
	
	print("BGM音量:",final_bgm)
	print("SFX音量:",final_sfx)
	# 正确的dB转换
	bgm_player.volume_db = linear_to_db(final_bgm / 100.0)
	sfx_player.volume_db = linear_to_db(final_sfx / 100.0)
	test_player.volume_db = sfx_player.volume_db

	# 静音时停止
	if final_bgm <= 0:
		stop_bgm()
	if final_sfx <= 0:
		sfx_player.stop()
		test_player.stop()


# ==============================
# 游戏音效
# ==============================
func play_select()->void:
	_apply_volume()
	if audio_select:
		sfx_player.stop()
		sfx_player.stream = audio_select
		sfx_player.play()

func play_hover()->void:
	_apply_volume()
	if audio_hover:
		sfx_player.stop()
		sfx_player.stream = audio_hover
		sfx_player.play()

func play_cancel()->void:
	_apply_volume()
	if audio_cancel:
		sfx_player.stop()
		sfx_player.stream = audio_cancel
		sfx_player.play()
# ==============================
# BGM
# ==============================
func play_bgm(bgm_key: String, duration: float = -1.0)->void:
	if not bgm_dict.has(bgm_key):
		print("BGM 不存在: ", bgm_key)
		return
	
	var path:String = bgm_dict[bgm_key]
	var audio: AudioStream = load(path) as AudioStream

	if not audio:
		return

	stop_bgm()
	_apply_volume()

	bgm_player.stream = audio
	bgm_player.play()

	if duration > 0:
		bgm_timer.wait_time = duration
		bgm_timer.start()

func stop_bgm()->void:
	if bgm_timer:
		bgm_timer.stop()
	if bgm_player:
		bgm_player.stop()

# ==============================
# 设置界面测试音效
# ==============================
func play_test_sfx()->void:
	_apply_volume()
	if test_sound:
		test_player.stream = test_sound
		test_player.play()
