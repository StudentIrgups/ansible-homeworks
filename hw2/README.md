## Решение

## 5-8
![Figure 1-1](https://github.com/StudentIrgups/ansible-homeworks/blob/main/hw2/images/1.png?raw=true)

![Figure 1-1](https://github.com/StudentIrgups/ansible-homeworks/blob/main/hw2/images/2.png?raw=true)

![Figure 1-1](https://github.com/StudentIrgups/ansible-homeworks/blob/main/hw2/images/3.png?raw=true)


Описание playbook
Плейбук выполняет установку кликхауса и вектора и далее настроивает их.

Установка и настройка ClickHouse
Параметры
  hosts: clickhouse
  become: true

Хэндлеры
Start clickhouse service
  ansible.builtin.service:
	name: clickhouse-server
	state: started
  tags:
	- clickhouse
	- start service
Теги: clickhouse, start service

Задачи
Get clickhouse distrib
  ansible.builtin.get_url:
	url: "https://packages.clickhouse.com/deb/pool/main/c/{{ item }}/{{ item }}_{{ clickhouse_version }}_amd64.deb"
	dest: "/tmp/{{ item }}-{{ clickhouse_version }}_amd64.deb"
	mode: '0644'
  with_items: "{{ clickhouse_packages }}"
  tags:
	- clickhouse
	- distr

Update apt cache
  ansible.builtin.apt:
	update_cache: true

Install clickhouse packages using dpkg
  ansible.builtin.command:
	cmd: "dpkg -i /tmp/{{ item }}-{{ clickhouse_version }}_amd64.deb"
  with_items: "{{ clickhouse_packages }}"
  notify: Start clickhouse service
  changed_when: false
  tags:
	- clickhouse
	- distr
	
Flush handlers
  ansible.builtin.meta: flush_handlers
  tags:
	- clickhouse
	- start service

Wait for clickhouse-server to be ready
  ansible.builtin.wait_for:
	host: localhost
	port: 9000
	delay: 10
	timeout: 300
  tags:
	- clickhouse
	- wait

Create database
  ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
  register: create_db
  failed_when: create_db.rc != 0 and create_db.rc != 82
  changed_when: create_db.rc == 0
  tags:
	- clickhouse
	- db

Установка и настройка Vector
  hosts: vector
  become: true

Хэндлеры
Start vector service
  ansible.builtin.service:
	name: vector
	state: restarted
  tags:
	- vector
	- restartservice

Задачи
Get vector distrib
  ansible.builtin.get_url:
	url: "https://packages.timber.io/vector/{{ vector_version }}/vector_{{ vector_version }}-1_amd64.deb"
	dest: "/tmp/vector-{{ vector_version }}.deb"
	mode: '0644'
  tags:
	- vector
	- distr

Update apt cache
  ansible.builtin.apt:
	update_cache: true

Install vector
  ansible.builtin.command:
	cmd: "dpkg -i /tmp/vector-{{ vector_version }}.deb"
  changed_when: false
  tags:
	- vector
	- distr

Deploy vector configuration
  ansible.builtin.template:
	src: templates/vector.yaml.j2
	dest: "{{ vector_config_path }}"
	mode: '0644'
  notify: Start vector service
  tags:
	- vector
	- config

Flush handlers
  ansible.builtin.meta: flush_handlers
  tags:
	- vector
	- restart service

Переменные
clickhouse_version: "22.8.5.29"
clickhouse_packages:
  - clickhouse-common-static
  - clickhouse-client
  - clickhouse-server
vector_version: "0.44.0"
vector_config_path: "/etc/vector/vector.yaml"