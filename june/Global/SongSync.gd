extends Node

## SINCRONIZAÇÃO P2P DE MÚSICAS NA REDE LOCAL (ISSUE #3)
## CADA INSTÂNCIA ANUNCIA POR UDP BROADCAST AS PASTAS QUE TEM EM user://songs,
## QUEM NÃO TEM UMA PASTA BAIXA ELA POR TCP DE QUEM ANUNCIOU.

const UDP_PORT : int = 47800
const TCP_PORT : int = 47801
const ANNOUNCE_INTERVAL : float = 3.0
const TIMEOUT_MSEC : int = 10000
## ponytail: A PASTA INTEIRA VAI NA MEMÓRIA DE UMA VEZ, TRANSFERIR POR ARQUIVO SE OS VÍDEOS FICAREM MAIORES QUE ISSO
const MAX_TRANSFER_BYTES : int = 1 << 30

var _udp := PacketPeerUDP.new()
var _server := TCPServer.new()
var _announce_timer : float = 0.0
var _pending : Dictionary = {} ## PASTAS SENDO BAIXADAS, SÓ ACESSADO NA MAIN THREAD

func _ready() -> void:
	if _udp.bind(UDP_PORT, "0.0.0.0") != OK or _server.listen(TCP_PORT) != OK:
		push_warning("SongSync: porta em uso, sincronização de músicas desativada.")
		set_process(false)
		return
	_udp.set_broadcast_enabled(true) ## BROADCAST SÓ FUNCIONA EM SOCKET IPV4, POR ISSO O BIND EM 0.0.0.0

func _process(delta: float) -> void:
	_announce_timer -= delta
	if _announce_timer <= 0:
		_announce_timer = ANNOUNCE_INTERVAL
		_announce()

	if _udp.get_available_packet_count() > 0:
		var local_folders := get_local_folders()
		while _udp.get_available_packet_count() > 0:
			var folders = _udp.get_var()
			var ip := _udp.get_packet_ip()
			if not folders is PackedStringArray:
				continue
			for folder in folders:
				if is_safe_name(folder) and not folder in local_folders and not _pending.has(folder):
					_pending[folder] = true
					WorkerThreadPool.add_task(_download.bind(ip, folder))

	while _server.is_connection_available():
		WorkerThreadPool.add_task(_serve.bind(_server.take_connection()))

## PASTAS DE MÚSICA COMPLETAS (COM song_map.json) NO PRIMEIRO NÍVEL DE user://songs
static func get_local_folders() -> PackedStringArray:
	var folders := PackedStringArray()
	for folder in DirAccess.get_directories_at(Global.SONGS_PATH):
		if is_safe_name(folder) and FileAccess.file_exists(Global.SONGS_PATH + "/" + folder + "/song_map.json"):
			folders.append(folder)
	return folders

## NOMES VINDOS DA REDE NÃO PODEM SAIR DA PASTA (.., /, \, ETC)
static func is_safe_name(value) -> bool:
	return value is String and value.is_valid_filename() and not value.begins_with(".")

func _announce() -> void:
	## ponytail: LISTA INTEIRA EM UM PACOTE UDP (~64KB, ALGUMAS CENTENAS DE MÚSICAS), PAGINAR SE PASSAR DISSO
	var packet := var_to_bytes(get_local_folders())
	var addresses := ["255.255.255.255"]
	## ponytail: ASSUME REDE /24, O GODOT NÃO EXPÕE A MÁSCARA DAS INTERFACES
	for address in IP.get_local_addresses():
		if address.count(".") == 3 and not address.begins_with("127."):
			addresses.append(address.substr(0, address.rfind(".")) + ".255")
	for address in addresses:
		_udp.set_dest_address(address, UDP_PORT)
		_udp.put_packet(packet)

func _serve(peer : StreamPeerTCP) -> void:
	var folder = _receive_var(peer)
	var files := {}
	if is_safe_name(folder) and folder in get_local_folders():
		var path : String = Global.SONGS_PATH + "/" + folder
		for file in DirAccess.get_files_at(path):
			files[file] = FileAccess.get_file_as_bytes(path + "/" + file)
	peer.put_var(files)
	peer.disconnect_from_host()

func _download(ip : String, folder : String) -> void:
	var peer := StreamPeerTCP.new()
	var files = null
	if peer.connect_to_host(ip, TCP_PORT) == OK and _wait_connected(peer):
		peer.put_var(folder)
		files = _receive_var(peer)
	peer.disconnect_from_host()

	var received : bool = files is Dictionary and files.has("song_map.json")
	if received:
		for file in files:
			if not is_safe_name(file) or not files[file] is PackedByteArray:
				received = false
	if received:
		received = _write_folder(folder, files)
	_download_finished.call_deferred(folder, received)

## ESCREVE NUMA PASTA OCULTA E SÓ RENOMEIA NO FINAL, A SELEÇÃO NUNCA VÊ MÚSICA PELA METADE
func _write_folder(folder : String, files : Dictionary) -> bool:
	var temp_path : String = Global.SONGS_PATH + "/.sync_" + folder
	DirAccess.make_dir_absolute(temp_path)
	for file in files:
		var file_access := FileAccess.open(temp_path + "/" + file, FileAccess.WRITE)
		if not file_access or not file_access.store_buffer(files[file]):
			return false
		file_access.close()
	return DirAccess.rename_absolute(temp_path, Global.SONGS_PATH + "/" + folder) == OK

func _download_finished(folder : String, received : bool) -> void:
	_pending.erase(folder)
	if received:
		print("SongSync: música recebida: ", folder)

func _wait_connected(peer : StreamPeerTCP) -> bool:
	var deadline := Time.get_ticks_msec() + TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		peer.poll()
		match peer.get_status():
			StreamPeerTCP.STATUS_CONNECTED:
				return true
			StreamPeerTCP.STATUS_CONNECTING:
				OS.delay_msec(10)
			_:
				return false
	return false

## MESMO FORMATO DO put_var, MAS COM TIMEOUT E LIMITE DE TAMANHO (O get_var BLOQUEIA PARA SEMPRE)
func _receive_var(peer : StreamPeerTCP) -> Variant:
	var size_bytes := _receive_bytes(peer, 4)
	if size_bytes.size() != 4:
		return null
	var size := size_bytes.decode_u32(0)
	if size > MAX_TRANSFER_BYTES:
		return null
	var data := _receive_bytes(peer, size)
	if data.size() != size:
		return null
	return bytes_to_var(data)

func _receive_bytes(peer : StreamPeerTCP, size : int) -> PackedByteArray:
	var data := PackedByteArray()
	var deadline := Time.get_ticks_msec() + TIMEOUT_MSEC
	while data.size() < size and Time.get_ticks_msec() < deadline:
		peer.poll()
		var result := peer.get_partial_data(size - data.size())
		if result[0] != OK:
			break
		if result[1].is_empty():
			OS.delay_msec(5)
			continue
		data.append_array(result[1])
		deadline = Time.get_ticks_msec() + TIMEOUT_MSEC
	return data
