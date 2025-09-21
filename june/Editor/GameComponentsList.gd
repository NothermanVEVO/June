extends ItemList

class_name GameComponents

const MINIMUM_SIZE_X : float = 25.0 # It's inside the SoundComponentsList too, needs to adjust that value

var is_resizing : bool = false
var mouse_position_when_down : Vector2
var start_minimum_size_x : float

@onready var sound_components := $"../Sound Components List"

static var _selected_item_text = ""

func _ready() -> void:
	## OMG PIRATE SOFTWARE???
	set_item_tooltip(1, "Consegue selecionar \"Notas\" e \"Notas Longas\", pode mexê-las de posição, copiar, além de\n apagá-las com \"Delete\"")
	set_item_tooltip(4, "Nota simples de apertar.")
	set_item_tooltip(5, "Nota de apertar, aperte com o mouse e arraste para usá-la, essas notas serão inválidas se começarem\n e acaberem no mesmo tempo.")
	set_item_tooltip(7, "Ativa ou desativa o efeito de \"Poder\" em uma nota do tipo Tap ou Hold.")
	set_item_tooltip(8, "A partir do tempo que a nota for posicionada, a velocidade mudará e ficara assim até\n o final ou até outra nota de velocidade, clique na nota com botão direito para alterar a velocidade.")
	set_item_tooltip(9, "Essa nota só funciona em pares, para cada Fade Out deve haver um Fade In, isso irá fazer com que a\n Gear desapareça até o momento do Fade In, clique na nota com botão direito para alterar o tipo de Fade.")
	set_item_tooltip(12, "Essa nota não altera em nada durante o jogo, ela só serve para caso você queria marcar posições da\n música, se clicar com o botão direito você pode fazer comentários nela.")
	set_item_tooltip(13, "Um song map poderá ser dividido em seções, a partir do momento da nota o jogo começara a contar estatísticas\n do jogador entre essa seção até o outra seção ou o final da música, clique com o botão direito para colocar um título.")

func _process(_delta: float) -> void:
	if Editor.editor_music_player and Editor.editor_music_player.visible:
		return
	
	if is_resizing:
		custom_minimum_size.x = start_minimum_size_x + (mouse_position_when_down.x - get_global_mouse_position().x)
		custom_minimum_size.x = MINIMUM_SIZE_X if custom_minimum_size.x < MINIMUM_SIZE_X else custom_minimum_size.x
		var max_pos = sound_components.size.x + MINIMUM_SIZE_X
		var screen_difference_x := get_viewport_rect().size.x - custom_minimum_size.x
		if screen_difference_x < max_pos:
			sound_components.custom_minimum_size.x = screen_difference_x - MINIMUM_SIZE_X
			if sound_components.custom_minimum_size.x < MINIMUM_SIZE_X:
				sound_components.custom_minimum_size.x = MINIMUM_SIZE_X
				custom_minimum_size.x = get_viewport_rect().size.x - max_pos
	
	if Input.is_action_just_pressed("Select"):
		_selected_item_text = "Selecionar (E)"
		select(1)
	elif Input.is_action_just_pressed("Tap"):
		_selected_item_text = "Tap (B)"
		select(4)
	elif Input.is_action_just_pressed("Hold") and not Input.is_action_just_pressed("Paste"):
		_selected_item_text = "Hold (V)"
		select(5)
	elif Input.is_action_just_pressed("Power"):
		_selected_item_text = "Poder (G)"
		select(7)
	elif Input.is_action_just_pressed("Speed") and not Input.is_action_pressed("Undo"):
		_selected_item_text = "Velocidade (Z)"
		select(8)
	elif Input.is_action_just_pressed("Fade"):
		_selected_item_text = "Fade (F)"
		select(9)
	elif Input.is_action_just_pressed("Note") and not Input.is_action_just_pressed("Copy"):
		_selected_item_text = "Comentário (C)"
		select(12)
	elif Input.is_action_just_pressed("Section"):
		_selected_item_text = "Seção (X)"
		select(13)

func _on_item_selected(index: int) -> void:
	
	_selected_item_text = get_item_text(index)
	
	release_focus()
	if Editor.editor_composer and Editor.editor_composer.editor_menu_bar and Editor.editor_composer.editor_menu_bar.game:
		Editor.editor_composer.editor_menu_bar.game.grab_focus()
	
	#match get_item_text(index):
		#"Select":
			#pass
		#"Un/lock":
			#pass
		#"Tap":
			#pass
		#"Hold":
			#pass
		#"Power":
			#pass
		#"Speed":
			#pass
		#"Fade":
			#pass
		#"Sound":
			#pass
		#"Note":
			#pass
		#_:
			#print("epa, NÃO ERA PRA ESTAR ENTRANDO AQUI, FICA ESPERTO")

func _on_resize_button_button_down() -> void:
	is_resizing = true
	mouse_position_when_down = get_global_mouse_position()
	start_minimum_size_x = custom_minimum_size.x
	set_process(true)

func _on_resize_button_button_up() -> void:
	is_resizing = false
	set_process(false)

static func get_selected_item_text():
	return _selected_item_text
