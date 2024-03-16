#!/bin/bash

get_network_info() {

    echo -n "Сетевая карта: "
    lspci | grep -i network | awk '{print $4, $5, $6, $7, $8}'

    echo -n "Канальная скорость: "
    ethtool enp0s3 | grep -i speed | awk '{print $2}'

    echo -n "Режим работы: "
    ethtool enp0s3 | grep -i duplex | awk '{print $2}'

    echo -n "Состояние линка: "
    if ethtool enp0s3 | grep -g 'Link detected: yes'; then
        echo "Подключение есть"
    else
        echo "Подключение отсутствует"
    fi

    echo -n "MAC адресс: "
    ip link show enp0s3 |awk '/ether/ {print $2}'
}

get_ipv4_info() {
    echo "Текущая конфигурация IPv4:"
    ip addr show dev eth0 | grep -w inet | awk '{print "IP:", $2}'
    ip route | grep -w 'default' | awk '{print "Шлюз:", $3}'
    grep -w 'nameserver' /etc/resolv.conf | awk '{print "DNS:", $2}'
}

configure_static() {
    echo "Настройка сетевого интерфейса по сценарию СТАТИЧЕСКАЯ АДРЕСАЦИЯ"
    ip addr add 10.100.0.2/24 dev eth0
    ip route add default via 10.100.0.1
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "Сетевой интерфейс настроен статически."
}

configure_dynamic() {
    echo "Настройка сетевого интерфейса по сценарию ДИНАМИЧЕСКАЯ АДРЕСАЦИЯ"
    dhclient eth0
    echo "Сетевой интерфейс настроен динамически."
}

while true; do
    echo "Выберите действие:"
    echo "a. Получить информацию о сетевой карте"
    echo "b. Получение информации о IPv4"
    echo "c. Настроить сетевой интерфейс по сценарию #1"
    echo "d. Настроить сетевой интерфейс по сценарию #2"
    echo "e. Закрыть скрипт"

    read choice

    case $choice in
        a) get_network_info ;;
        b) get_ipv4_info ;;
        c) configure_static ;;
        d) configure_dynamic ;;

        e) break ;;
        *) echo "Некорректный выбор. Попробуйте еще раз." ;;
    esac
done