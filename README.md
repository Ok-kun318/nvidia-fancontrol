# このスクリプトについて
このスクリプトはGPUのファンを制御するためのものです
```bash
nvidia-smi
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits
```
の2つが実行できるか確認してください
また、
```
nvidia-settings -a GPUFanControlState=1 -a GPUTargetFanSpeed=100
sleep 5
nvidia-settings -a GPUFanControlState=0
```
を実行してファンの速度が5秒間100%になるか確認してください

できない場合は

```

cd /./etc/X11/
sudo -s
gnome-text-editor Xwrapper.config
```
そしたらテキストエディタがい開くと思うので
needs_root_rights=yes
のあとに
allowed_users=console
と入れます

## 例
# 使い方
fan_temp_config
fan_speed_config
に数字を入れます

```
fan_temp_config=(40 45 50 55 60)
fan_speed_config=(30 35 40 45 100)
```
この場合は
| GPU温度 | ファンの回転数                                 | 
| ------- | ---------------------------------------------- | 
| ~40     | AUTO (nvidia-settings -a GPUFanControlState=0) | 
| 40~45   | 30                                             | 
| 45~50   | 35                                             | 
| 50~55   | 40                                             | 
| 55~60   | 45                                             | 
| 60~     | 100                                            | 

> [!TIP]
> 末尾の数字は~40を除いて以下になります
