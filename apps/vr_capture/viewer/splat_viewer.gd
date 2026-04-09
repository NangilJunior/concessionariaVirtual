extends Node3D

@onready var origin: XROrigin3D = $XROrigin3D
@onready var camera: XRCamera3D = $XROrigin3D/XRCamera3D

var ply_path: String = ""

func _ready() -> void:
	# Read the currently active project
	if not ProjectManager.current_project.is_empty():
		ply_path = ProjectManager.current_project.get("ply_local_path", "")
		if ply_path != "" and FileAccess.file_exists(ply_path):
			_load_splat(ply_path)
		else:
			print("Erro: Arquivo .ply não encontrado!")
	
	setup_xr()

func setup_xr() -> void:
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR inicializado com sucesso.")
		get_viewport().use_xr = true
	else:
		print("OpenXR não está disponível no Visualizador.")

func _load_splat(path: String) -> void:
	print("Carregando Splat do caminho: ", path)
	
	# OBSERVAÇÃO PARA O DESENVOLVEDOR:
	# Quando o plugin de Gaussian Splatting (ex: godot-splatter) for instalado,
	# instancie o nó correspondente dele aqui e defina o 'path' do modelo.
	var splat_node = Node3D.new() 
	splat_node.name = "GaussianSplatModel"
	add_child(splat_node)
	
	# Fallback visual de placeholder até o plugin ser ativado
	var mesh_inst = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(1, 1, 1)
	mesh_inst.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0, 0)
	mesh_inst.material_override = mat
	mesh_inst.position = Vector3(0, 1.5, -2) # Na frente da câmera
	splat_node.add_child(mesh_inst)

func _process(_delta: float) -> void:
	pass

func exit_viewer() -> void:
	get_viewport().use_xr = false
	get_tree().change_scene_to_file("res://home/project_list_screen.tscn")
