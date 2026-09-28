# Ferramentas June

Todas as ferramentas vivem em um script Python 3.10+ que usa apenas stdlib: `junes.py`
(além de `june_installer.py`, o script de entrada empacotado por `build-installer`).

```
python tools/junes.py <command> ...
```

## Formato: `.junes`

Um arquivo `.junes` é um arquivo ZIP (deflate) que espelha os dados de músicas `user://` do June
(`songs/` e `sideeditor/`, ou seja, `Global.SONGS_PATH` e
`Global.SIDE_EDITOR_PATH` do Godot). Suas únicas entradas de nível superior são `songs/...`
e/ou `sideeditor/...` — pelo menos uma das duas deve estar presente. O arquivo inteiro é rejeitado (proteção zip-slip) se estiver vazio ou se alguma entrada estiver
fora dessas raízes, for absoluta, ou contiver `\`, `:`, ou um segmento de caminho vazio, `.` ou
`..`. `junes.py` e o jogo (`june/Global/Global.gd`) aplicam
as mesmas regras.

### `pack`

Constrói um arquivo `.junes` a partir de uma pasta:

```
python tools/junes.py pack <source_dir> [-o <name>.junes]
```

- `source_dir` deve conter `songs/`, `sideeditor/`, ou `sidesongs/sideeditor/`
  (a forma aninhada é armazenada como `sideeditor/` no arquivo). Pelo menos um
  de `songs/` ou `sideeditor/` deve ser uma pasta real, ou o comando
  falha com um erro claro. Se alguma dessas pastas existir mas estiver vazia, o comando
  também falha com um erro.
- Saída padrão: `<source_dir name>.junes`, escrito no diretório atual.
- `-o/--output` escolhe um caminho de saída diferente.

Exemplo, empacotando os dados de aplicativo de amostra usados durante o desenvolvimento:

```
python tools/junes.py pack /path/to/.appdata -o mysongs.junes
```

### `install`

Instala um executável June e o popula com um arquivo `.junes`:

```
python tools/junes.py install <executable> <file.junes> [--install-dir DIR]
```

- Copia `<executable>` para o diretório de instalação (padrão: `%LOCALAPPDATA%\Programs\June`
  no Windows, `~/.local/opt/June` no Linux; feito executável lá no Linux).
- Inicia-o brevemente para que June crie seus próprios diretórios `user://`, depois
  para ele.
- Extrai `<file.junes>` no diretório de dados do usuário Godot do June (`%APPDATA%\June`
  no Windows, `$XDG_DATA_HOME/June` ou `~/.local/share/June` no Linux),
  sobrescrevendo quaisquer arquivos já presentes.
- Inicia June novamente e sai.
- `--install-dir` sobrescreve o diretório de instalação padrão.

A validação de `.junes` acontece antes de qualquer coisa ser copiada, então um arquivo
inseguro ou corrompido aborta a instalação sem fazer alterações.

### `export`

Agrupa um arquivo `.junes` em uma exportação Godot headless do June:

```
python tools/junes.py export <file.junes> <output path> [--godot PATH] [--preset NAME]
```

- Valida `<file.junes>` primeiro, exatamente como `install`.
- `--godot` escolhe o binário Godot; o padrão é a variável de ambiente `GODOT`,
  senão `godot` no `PATH`.
- `--preset` escolhe o preset de `export_presets.cfg`; o padrão é `June Windows`
  no Windows e `June Linux` em outro lugar.
- Copia `<file.junes>` para `june/bundled_songs.junes` (para que seja embutido
  no `.pck` da compilação de acordo com o `include_filter` de `export_presets.cfg`), executa
  `godot --headless --path june --export-release <preset> <output path>`,
  depois sempre remove o arquivo copiado depois. Se um `bundled_songs.junes`
  já existisse em `june/`, é feito backup primeiro e restaurado depois
  em vez de ser deletado, para que a árvore do projeto seja deixada exatamente como estava.
- O diretório pai da saída é criado se não existir.
- Sai com o código de saída do próprio Godot, então falhas de exportação são visíveis para
  scripts/CI.

Na inicialização, June extrai `res://bundled_songs.junes` (se presente) em
`user://` sem sobrescrever arquivos existentes — veja `june/Global/Global.gd`.

### `build-installer`

Constrói um executável instalador autossuficiente com um arquivo `.junes` embutido:

```
python tools/junes.py build-installer <file.junes> [-o DIST_DIR]
```

- Precisa de PyInstaller apenas na máquina de compilação (`pip install pyinstaller`);
  o comando avisa se estiver faltando. Usuários finais não precisam de nada instalado.
- Valida `<file.junes>`, depois executa PyInstaller (`--onefile --name
  JuneInstaller`) em `tools/june_installer.py`, embutindo o `.junes`.
  Arquivos de compilação vão para um diretório temporário; o executável vai para `DIST_DIR`
  (padrão `./dist`). Sai com o código de saída do PyInstaller.
- Sem compilações cruzadas: PyInstaller compila para o SO em que é executado. Execute
  no Windows para obter `JuneInstaller.exe`, no Linux para obter um `JuneInstaller` Linux.

Quando um usuário final executa `JuneInstaller`, ele:

1. Pede ao GitHub a versão mais recente do June
   (`api.github.com/repos/NothermanVEVO/June/releases/latest`).
2. Escolhe o zip da versão cujo nome contém `windows` ou `linux` para o
   SO atual.
3. Baixa e extrai para um diretório temporário e encontra o binário June
   (`*.exe` no Windows, `*.x86_64` no Linux). Problemas de rede (sem internet,
   limite de taxa do GitHub HTTP 403/429) interrompem o instalador aqui, antes de
   qualquer coisa ser instalada.
4. Executa os mesmos passos de `install` com o diretório de instalação padrão e o
   `.junes` embutido: copia June, abre por 3 s, fecha, extrai as músicas
   em `user://`, abre June novamente.

Cada passo é impresso; no Windows a janela aguarda Enter após qualquer erro.

## Testes

Os testes para `junes.py` são executados com `python -m unittest` a partir do diretório `tools/`:

```
python -m unittest
```

Os testes estão em `tools/test_junes.py` e usam apenas stdlib — sem dependências externas.
