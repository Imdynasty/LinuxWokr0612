#!/bin/bash

# Threshold 설정
CPU_THRESHOLD=5
MEMORY_THRESHOLD=5
DISK_THRESHOLD=5

# Log 파일 경로
LOG_FILE="monitor.log"

# 현재 시간을 포맷에 맞게 반환하는 함수
get_current_time() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 알림을 보내는 함수
send_alert() {
    local resource=$1
    local usage=$2
    echo "$(get_current_time) - $resource 사용량이 $usage%로 임계값을 초과했습니다." >> $LOG_FILE
    curl -s -o /dev/null -H "Content-Type: application/json" -d "{\"text\": \"임계값
 초과해서 관리자에게 메시지를 보냅니다. $(date +%Y-%m-%dT%H:%M:%S).\"}" "https://o365kopo.webhook.office.com/webhookb2/6c4e7625-c5c7-4974-986f-9fe1687ad4b5@ad21525c-fc0f-4dbc-a403-67ce00add0e4/IncomingWebhook/ce3d67a4d81a458e8b1517539286b367/1580fd1d-48be-4ed4-aad8-0567b9784892"

}

# 모니터링 함수
monitor_resources() {
    # 테스트를 위해 3번 실행	
    for i in {1..3}
    do
        # 현재 시간
        current_time=$(get_current_time)

        # CPU, 메모리, 디스크 사용량 가져오기, 정수로 변환
        cpu=$(top -bn1 | grep "Cpu" | awk '{printf("%d\n", 100 - $8)}')
        memory=$(top -bn1 | grep "MiB 메모리" | awk '{printf("%d\n", $8)}')
        disk=$(df -h | grep "/dev/sda3" | awk '{printf("%d\n", $5)}')
        # 로그에 기록
        echo "$current_time - CPU 사용량: $cpu%, 메모리 사용량: $memory%, 디스크 사용량: $disk%" >> $LOG_FILE

        # 임계값을 초과하는 경우 알림 보내기
        if [ $cpu -gt $CPU_THRESHOLD ]; then
            send_alert "CPU" $cpu
        fi

        if [ $memory -gt $MEMORY_THRESHOLD ]; then
		 	    send_alert "memory" $memory
        fi

        if [ $disk -gt $DISK_THRESHOLD ]; then
            send_alert "Disk" $disk
        fi

        # for 문 종료 후 10초 후 반복
        sleep 10
    done
}

# 모니터링 시작
monitor_resources
