#!/usr/bin/env bash
# Teste da sincronização P2P de músicas (issue #3).
# Sobe duas instâncias headless do jogo em containers na mesma rede Docker:
# A começa com uma música, B precisa recebê-la idêntica.
# Uso: GODOT=/caminho/Godot_v4.7.x-stable_linux.x86_64 ./tests/song_sync_test.sh
set -euo pipefail

GODOT=$(realpath "${GODOT:?defina GODOT com o binário Linux do Godot 4.7}")
PROJECT=$(cd "$(dirname "$0")/.." && pwd)
NET=june-sync-test
SONGS=/root/.local/share/June/songs

cleanup() { docker rm -f june-a june-b >/dev/null 2>&1 || true; docker network rm "$NET" >/dev/null 2>&1 || true; }
trap cleanup EXIT; [ -n "${KEEP:-}" ] && trap - EXIT
cleanup
docker network create "$NET" >/dev/null

run() {
	docker run -d --name "$1" --network "$NET" -v "$GODOT":/godot:ro -v "$PROJECT":/src:ro debian:bookworm-slim \
		bash -c "$2 cp -r /src /game && /godot --headless --path /game --import >/dev/null 2>&1; /godot --headless --path /game" >/dev/null
}
run june-a "mkdir -p $SONGS/teste && echo '{}' > $SONGS/teste/song_map.json && head -c 50000000 /dev/urandom > $SONGS/teste/video.ogv &&"
run june-b ""

for _ in $(seq 90); do
	if docker exec june-b test -f "$SONGS/teste/video.ogv"; then
		a=$(docker exec june-a md5sum "$SONGS/teste/video.ogv" | cut -d' ' -f1)
		b=$(docker exec june-b md5sum "$SONGS/teste/video.ogv" | cut -d' ' -f1)
		[ "$a" = "$b" ] && echo "OK: música sincronizada" && exit 0
		echo "FALHOU: arquivo diferente"; exit 1
	fi
	sleep 2
done
docker logs june-b 2>&1 | tail -30
echo "FALHOU: música não chegou em B"
exit 1
