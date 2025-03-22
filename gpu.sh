#!/bin/bash
# 温度とファン速度の設定
fan_temp_config=(40 45 50 55 60)
fan_speed_config=(30 35 40 45 100)

trap 'reset_fan_control; echo "終了します。";exit' SIGINT
# ループ間隔（秒）
INTERVAL=1

# 手動ファン制御を有効にする関数
set_fan_speed() {
	nvidia-settings -a GPUFanControlState=1
	nvidia-settings -a GPUTargetFanSpeed=$1
}

# 自動制御に戻す関数
reset_fan_control() {
	nvidia-settings -a GPUFanControlState=0
}

# スクリプト開始時に現在のファン速度を取得
before_fan_speed=$(nvidia-smi --query-gpu=fan.speed --format=csv,noheader,nounits | tr -d '%')
before_control_state=1

while true; do
	# GPUの温度を取得
	TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
	FAN_SPEED=$(nvidia-smi --query-gpu=fan.speed --format=csv,noheader,nounits | tr -d '%')

	# 40度以下は自動制御
	if [ "$TEMP" -le "${fan_temp_config[0]}" ]; then
		if [ "$before_control_state" -eq 1 ]; then
			reset_fan_control
			before_control_state=0
		fi
		echo "GPU Temp: $TEMP°C, Fan Control: Auto"
	else
		before_control_state=1
		TARGET_FAN_SPEED=${fan_speed_config[-1]} # 初期値は最大値

		# 設定リストをループして適切なファン速度を決定
		for ((i = 0; i < ${#fan_temp_config[@]}; i++)); do
			if [ "$TEMP" -lt "${fan_temp_config[$i]}" ]; then
				TARGET_FAN_SPEED=${fan_speed_config[$i]}
				break
			fi
		done
		set_fan_speed "$TARGET_FAN_SPEED"

		# **常に温度とファン速度を表示**
		echo "GPU Temp: $TEMP°C, Fan Speed: $TARGET_FAN_SPEED% be:$before_fan_speed%"
	fi
	sleep $INTERVAL
done
