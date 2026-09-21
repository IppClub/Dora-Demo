import math
import os
import re
import struct
import json

import bpy


ROOT = "/Users/Jin/Workspace/Dora/3D-Adv-Game/Dora"
SOURCE = os.path.join(ROOT, "Assets/Unity/Assets/Art/ChineseSample")
OUTPUT = os.path.join(ROOT, "Assets/Model")
GENERATED = os.path.join(ROOT, "Assets/Unity/Assets/ReturningHome30/Generated")
os.makedirs(OUTPUT, exist_ok=True)


def clear_scene():
	bpy.ops.object.select_all(action="SELECT")
	bpy.ops.object.delete(use_global=False)
	for collection in (bpy.data.meshes, bpy.data.curves, bpy.data.materials, bpy.data.armatures, bpy.data.actions):
		for item in list(collection):
			if item.users == 0:
				collection.remove(item)


def material(name, color, metallic=0.0, roughness=0.75, emission=None):
	mat = bpy.data.materials.new(name)
	mat.diffuse_color = (*color, 1.0)
	mat.use_nodes = True
	bsdf = mat.node_tree.nodes.get("Principled BSDF")
	bsdf.inputs["Base Color"].default_value = (*color, 1.0)
	bsdf.inputs["Metallic"].default_value = metallic
	bsdf.inputs["Roughness"].default_value = roughness
	if emission is not None:
		bsdf.inputs["Emission"].default_value = (*emission, 1.0)
		bsdf.inputs["Emission Strength"].default_value = 2.5
	return mat


CHANNEL_NAMES = [
	"position", "normal", "tangent", "color", "uv0", "uv1", "uv2", "uv3",
	"uv4", "uv5", "uv6", "uv7", "blendWeight", "blendIndices",
]


def parse_unity_mesh(path):
	"""Read the uncompressed Unity YAML mesh format used by this project."""
	text = open(path, "r", encoding="utf-8").read()
	vertex_count = int(re.search(r"m_VertexCount: (\d+)", text).group(1))
	index_format = int(re.search(r"m_IndexFormat: (\d+)", text).group(1))
	index_hex = re.search(r"m_IndexBuffer: ([0-9a-f]+)", text).group(1)
	data_hex = re.search(r"_typelessdata: ([0-9a-f]+)", text).group(1)
	channel_block = re.search(r"m_Channels:\n(.*?)    m_DataSize:", text, re.S).group(1)
	channels = []
	for match in re.finditer(r"- stream: (\d+)\n\s+offset: (\d+)\n\s+format: (\d+)\n\s+dimension: (\d+)", channel_block):
		channels.append(tuple(map(int, match.groups())))
	data = bytes.fromhex(data_hex)
	format_size = {0: 4, 10: 4}
	strides = {}
	for stream, offset, fmt, dimension in channels:
		if dimension:
			strides[stream] = max(strides.get(stream, 0), offset + format_size[fmt] * dimension)
	stream_starts = {}
	cursor = 0
	for stream in sorted(strides):
		stream_starts[stream] = cursor
		cursor += strides[stream] * vertex_count
	attributes = {}
	for semantic, channel in zip(CHANNEL_NAMES, channels):
		stream, offset, fmt, dimension = channel
		if not dimension:
			continue
		values = []
		code = "f" if fmt == 0 else "I"
		for index in range(vertex_count):
			start = stream_starts[stream] + index * strides[stream] + offset
			values.append(struct.unpack_from("<" + code * dimension, data, start))
		attributes[semantic] = values
	index_code = "H" if index_format == 0 else "I"
	index_size = 2 if index_format == 0 else 4
	index_data = bytes.fromhex(index_hex)
	indices = list(struct.unpack("<" + index_code * (len(index_data) // index_size), index_data))
	return attributes, indices


def vertex_color_material(name, tint=(1, 1, 1)):
	mat = material(name, tint, roughness=0.82)
	vertex = mat.node_tree.nodes.new("ShaderNodeVertexColor")
	vertex.layer_name = "Color"
	bsdf = mat.node_tree.nodes.get("Principled BSDF")
	mat.node_tree.links.new(vertex.outputs["Color"], bsdf.inputs["Base Color"])
	return mat


def unity_mesh_object(path, name, mat=None, fbx_skin_space=False, cat_arm_angle=None):
	attributes, indices = parse_unity_mesh(path)
	if cat_arm_angle is not None:
		posed_positions = []
		posed_normals = []
		for position, normal, weights, bone_indices in zip(attributes["position"], attributes["normal"], attributes["blendWeight"], attributes["blendIndices"]):
			bone = bone_indices[max(range(4), key=lambda index: weights[index])]
			angle = 0.0
			pivot = (0.0, 0.0)
			if bone in (13, 14, 15):
				angle = math.radians(cat_arm_angle)
				pivot = (-0.13, 0.82)
			elif bone in (30, 31, 32):
				angle = -math.radians(cat_arm_angle)
				pivot = (0.13, 0.82)
			x, y, z = position
			dx, dy = x - pivot[0], y - pivot[1]
			posed_positions.append((pivot[0] + dx * math.cos(angle) - dy * math.sin(angle), pivot[1] + dx * math.sin(angle) + dy * math.cos(angle), z))
			nx, ny, nz = normal
			posed_normals.append((nx * math.cos(angle) - ny * math.sin(angle), nx * math.sin(angle) + ny * math.cos(angle), nz))
		attributes["position"] = posed_positions
		attributes["normal"] = posed_normals
	if fbx_skin_space:
		# The imported FBX armature keeps centimeter mesh coordinates and applies
		# a 0.01 scale plus Y-up conversion on its object matrix. Unity's generated
		# skin has the opposite X handedness, proven by matching all inverse bind
		# positions against the named FBX bones, so mirror X in mesh-local space.
		attributes["position"] = [(-x * 100, y * 100, z * 100) for x, y, z in attributes["position"]]
		if "normal" in attributes:
			attributes["normal"] = [(-x, y, z) for x, y, z in attributes["normal"]]
	else:
		# Unity stores Y-up coordinates. Blender-authored geometry is Z-up and its
		# glTF exporter converts back to Y-up, so import Unity (x,y,z) as (x,-z,y).
		attributes["position"] = [(x, -z, y) for x, y, z in attributes["position"]]
		if "normal" in attributes:
			attributes["normal"] = [(x, -z, y) for x, y, z in attributes["normal"]]
	mesh = bpy.data.meshes.new(name)
	faces = [indices[i:i + 3] for i in range(0, len(indices), 3)]
	mesh.from_pydata(attributes["position"], [], faces)
	mesh.update()
	if "normal" in attributes:
		try:
			mesh.normals_split_custom_set_from_vertices(attributes["normal"])
		except RuntimeError:
			pass
	if "color" in attributes:
		colors = mesh.color_attributes.new(name="Color", type="FLOAT_COLOR", domain="POINT")
		for entry, rgba in zip(colors.data, attributes["color"]):
			# Unity's custom Ink shader consumed vertex RGB as display-space color;
			# glTF defines COLOR_0 as linear. Decode here so Dora reproduces Unity.
			entry.color = (rgba[0] ** 2.2, rgba[1] ** 2.2, rgba[2] ** 2.2, rgba[3])
	obj = bpy.data.objects.new(name, mesh)
	bpy.context.collection.objects.link(obj)
	obj.data.materials.append(mat or vertex_color_material(name + "顶点色"))
	return obj, attributes


def unity_rigid_parts(path, name):
	"""Split the generated cat mesh by its rigid Unity bone assignment."""
	attributes, indices = parse_unity_mesh(path)
	dominant = [bone_indices[max(range(4), key=lambda index: weights[index])] for weights, bone_indices in zip(attributes["blendWeight"], attributes["blendIndices"])]
	faces_by_bone = {}
	for i in range(0, len(indices), 3):
		face = indices[i:i + 3]
		bones = [dominant[index] for index in face]
		bone = max(set(bones), key=bones.count)
		faces_by_bone.setdefault(bone, []).append(face)
	shared_material = vertex_color_material(name + "顶点色")
	parts = {}
	for bone, faces in faces_by_bone.items():
		used = sorted({index for face in faces for index in face})
		remap = {old: new for new, old in enumerate(used)}
		positions = [(attributes["position"][i][0], -attributes["position"][i][2], attributes["position"][i][1]) for i in used]
		normals = [(attributes["normal"][i][0], -attributes["normal"][i][2], attributes["normal"][i][1]) for i in used]
		mesh = bpy.data.meshes.new(name + "_" + str(bone))
		mesh.from_pydata(positions, [], [[remap[index] for index in face] for face in faces])
		mesh.update()
		try:
			mesh.normals_split_custom_set_from_vertices(normals)
		except RuntimeError:
			pass
		colors = mesh.color_attributes.new(name="Color", type="FLOAT_COLOR", domain="POINT")
		for entry, source_index in zip(colors.data, used):
			rgba = attributes["color"][source_index]
			entry.color = (rgba[0] ** 2.2, rgba[1] ** 2.2, rgba[2] ** 2.2, rgba[3])
		obj = bpy.data.objects.new(name + "_" + str(bone), mesh)
		bpy.context.collection.objects.link(obj)
		obj.data.materials.append(shared_material)
		parts[bone] = obj
	return parts


def finish(name, apply_transforms=True):
	bpy.ops.object.select_all(action="SELECT")
	bpy.ops.export_scene.gltf(
		filepath=os.path.join(OUTPUT, name + ".glb"),
		export_format="GLB",
		export_apply=apply_transforms,
		export_animations=True,
		export_yup=True,
	)


def lock_horizontal_root_motion(path, clip_name):
	"""Make a locomotion clip in-place while preserving vertical body motion."""
	data = bytearray(open(path, "rb").read())
	json_size, _ = struct.unpack_from("<II", data, 12)
	document = json.loads(data[20:20 + json_size])
	bin_header = 20 + json_size
	bin_start = bin_header + 8
	for animation in document.get("animations", []):
		if animation.get("name") != clip_name:
			continue
		for channel in animation["channels"]:
			target = channel["target"]
			if target["path"] != "translation" or document["nodes"][target["node"]].get("name") != "Root":
				continue
			accessor = document["accessors"][animation["samplers"][channel["sampler"]]["output"]]
			view = document["bufferViews"][accessor["bufferView"]]
			start = bin_start + view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
			stride = view.get("byteStride", 12)
			first_x, _, first_z = struct.unpack_from("<fff", data, start)
			for index in range(accessor["count"]):
				offset = start + index * stride
				struct.pack_into("<f", data, offset, first_x)
				struct.pack_into("<f", data, offset + 8, first_z)
	open(path, "wb").write(data)


def cube(name, scale, location, mat, bevel=0.0):
	bpy.ops.mesh.primitive_cube_add(size=1, location=location)
	obj = bpy.context.object
	obj.name = name
	obj.dimensions = scale
	bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
	if bevel:
		modifier = obj.modifiers.new("Soft edges", "BEVEL")
		modifier.width = bevel
		modifier.segments = 2
	obj.data.materials.append(mat)
	return obj


def export_cat(source_name, clip_name, output_name):
	clear_scene()
	bpy.ops.import_scene.fbx(filepath=os.path.join(SOURCE, source_name + ".fbx"), use_anim=True)
	armature = next(obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE")
	original = next(obj for obj in bpy.context.scene.objects if obj.type == "MESH")
	cat, attributes = unity_mesh_object(
		os.path.join(SOURCE, "CatHanfuSkin.asset"), "橘猫汉服",
		vertex_color_material("橘猫汉服顶点色"), fbx_skin_space=True,
	)
	# Unity renderer order recovered from CatHanfuSkin's inverse bind poses.
	bone_names = [
		"Root", "Hips", "LeftLeg", "LeftCalf", "LeftFoot", "LeftFoorEND", "RightLeg", "RightCalf",
		"RightFoot", "RightFoorEND", "Spine1", "Spine2", "LeftShoulder", "LeftArm", "LeftForeArm",
		"LeftHand", "LeftHandEND", "Neck", "Head", "HeadEND", "LeftEye", "LeftEyebrow", "LeftEyelidDown",
		"LeftEyelidUp", "Mouth", "RightEye", "RightEyebrow", "RightEyelidDown", "RightEyelidUp",
		"RightShoulder", "RightArm", "RightForeArm", "RightHand", "RightHandEND",
	]
	groups = {}
	for bone_index, bone_name in enumerate(bone_names):
		if bone_name != "Root" and bone_name in armature.data.bones:
			groups[bone_index] = cat.vertex_groups.new(name=bone_name)
	for vertex_index, (weights, bone_indices) in enumerate(zip(attributes["blendWeight"], attributes["blendIndices"])):
		for weight, bone_index in zip(weights, bone_indices):
			if weight > 0.0 and bone_index in groups:
				groups[bone_index].add([vertex_index], weight, "REPLACE")
	cat.parent = armature
	cat.matrix_parent_inverse = original.matrix_parent_inverse.copy()
	cat.matrix_basis = original.matrix_basis.copy()
	modifier = cat.modifiers.new("Unity Skin", "ARMATURE")
	modifier.object = armature
	if armature.animation_data and armature.animation_data.action:
		armature.animation_data.action.name = clip_name
	bpy.data.objects.remove(original, do_unlink=True)
	finish(output_name, False)
	if clip_name == "walk":
		lock_horizontal_root_motion(os.path.join(OUTPUT, output_name + ".glb"), clip_name)


export_cat("CatIdle", "idle", "cat-idle")
export_cat("CatWalk", "walk", "cat-walk")

# A unit floor tile with an inset stone slab.
clear_scene()
stone = material("青石", (0.28, 0.37, 0.34), roughness=0.95)
grout = material("石缝", (0.035, 0.055, 0.05), roughness=1.0)
cube("地基", (2.0, 0.08, 2.0), (0, -0.04, 0), grout)
for x in (-0.48, 0.48):
	for z in (-0.48, 0.48):
		cube("青石板", (0.9, 0.035, 0.9), (x, 0.02, z), stone, 0.025)
finish("floor")

# White plaster wall, dark timber cap and base, matching the Unity courtyard palette.
clear_scene()
plaster = material("粉墙", (0.62, 0.67, 0.58), roughness=0.92)
wood = material("乌木", (0.16, 0.075, 0.038), roughness=0.82)
cube("粉墙", (2.0, 1.75, 0.28), (0, 0.88, 0), plaster, 0.04)
cube("墙脚", (2.08, 0.16, 0.38), (0, 0.08, 0), wood, 0.025)
cube("压顶木梁", (2.15, 0.18, 0.45), (0, 1.83, 0), wood, 0.035)
finish("wall")

clear_scene()
wood = material("朱漆木", (0.34, 0.055, 0.035), roughness=0.7)
gold = material("旧金", (0.72, 0.45, 0.11), metallic=0.45, roughness=0.42)
cube("立柱", (0.34, 2.4, 0.34), (0, 1.2, 0), wood, 0.05)
cube("柱础", (0.56, 0.22, 0.56), (0, 0.11, 0), gold, 0.04)
finish("pillar")

clear_scene()
unity_mesh_object(
	os.path.join(SOURCE, "PaperGuardianMesh.asset"),
	"巡灯纸人",
	vertex_color_material("纸人水墨顶点色"),
)
finish("guardian")

clear_scene()
unity_mesh_object(
	os.path.join(SOURCE, "LanternMesh.asset"),
	"古宅灯笼",
	vertex_color_material("古宅灯笼水墨顶点色"),
)
finish("lantern")

clear_scene()
unity_mesh_object(
	os.path.join(GENERATED, "Pickup_0_2_2.asset"),
	"灯印",
	vertex_color_material("灯印水墨顶点色"),
)
finish("seal")

clear_scene()
unity_mesh_object(
	os.path.join(GENERATED, "Pickup_0_6_2.asset"),
	"古铜钱",
	vertex_color_material("古铜钱水墨顶点色"),
)
finish("coin")

clear_scene()
unity_mesh_object(
	os.path.join(GENERATED, "Exit_0.asset"),
	"朱门出口",
	vertex_color_material("朱门水墨顶点色"),
)
finish("gate")


def join_named(objects, name):
	if not objects:
		return
	bpy.ops.object.select_all(action="DESELECT")
	for obj in objects:
		obj.select_set(True)
	bpy.context.view_layer.objects.active = objects[0]
	bpy.ops.object.join()
	objects[0].name = name


for chapter_index in range(3):
	clear_scene()
	for suffix, label in (("Floor", "青砖地面"), ("Walls", "院墙"), ("Decor", "庭院陈设")):
		unity_mesh_object(os.path.join(GENERATED, str(chapter_index) + "_" + suffix + ".asset"), label, vertex_color_material(label + "顶点色", (0.48, 0.54, 0.51)))
	finish("chapter-" + str(chapter_index))

print("RETURNING_HOME_ASSETS_EXPORTED", sorted(os.listdir(OUTPUT)))
