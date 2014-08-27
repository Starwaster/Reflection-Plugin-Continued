Shader "Reflective/Bumped Unlit" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	_MainTex ("Base (RGB), RefStrength (A)", 2D) = "white" {}
	_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }
	_BumpMap ("Normalmap", 2D) = "bump" {}
}

Category {
	Tags { "RenderType"="Opaque" }
	LOD 250
	
	// ------------------------------------------------------------------
	// Shaders

	SubShader {
		// Always drawn reflective pass
		Pass {
			Name "BASE"
			Tags {"LightMode" = "Always"}
Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 28 to 28
//   d3d9 - ALU: 31 to 31
//   d3d11 - ALU: 27 to 27, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 27 to 27, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Bind "texcoord" TexCoord0
Vector 9 [_WorldSpaceCameraPos]
Matrix 5 [_Object2World]
Vector 10 [unity_Scale]
Vector 11 [_MainTex_ST]
Vector 12 [_BumpMap_ST]
"!!ARBvp1.0
# 28 ALU
PARAM c[13] = { program.local[0],
		state.matrix.mvp,
		program.local[5..12] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R0.w, c[10];
MUL R3.xyz, R0.w, c[6];
MUL R2.xyz, R0.w, c[5];
MUL R4.xyz, R0.w, c[7];
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MUL R1.xyz, R0, vertex.attrib[14].w;
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
ADD R0.xyz, -R0, c[9];
DP3 result.texcoord[3].y, R2, R1;
DP3 result.texcoord[4].y, R1, R3;
DP3 result.texcoord[5].y, R1, R4;
MOV result.texcoord[2].xyz, -R0;
DP3 result.texcoord[3].z, vertex.normal, R2;
DP3 result.texcoord[3].x, R2, vertex.attrib[14];
DP3 result.texcoord[4].z, vertex.normal, R3;
DP3 result.texcoord[4].x, vertex.attrib[14], R3;
DP3 result.texcoord[5].z, vertex.normal, R4;
DP3 result.texcoord[5].x, vertex.attrib[14], R4;
MAD result.texcoord[0].xy, vertex.texcoord[0], c[11], c[11].zwzw;
MAD result.texcoord[1].xy, vertex.texcoord[0], c[12], c[12].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 28 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [_MainTex_ST]
Vector 11 [_BumpMap_ST]
"vs_2_0
; 31 ALU
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
dcl_texcoord0 v3
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r1.xyz, r0, v1.w
mov r0.xyz, c5
mul r3.xyz, c9.w, r0
mov r0.xyz, c6
mul r4.xyz, c9.w, r0
mov r2.xyz, c4
mul r2.xyz, c9.w, r2
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
add r0.xyz, -r0, c8
dp3 oT3.y, r2, r1
dp3 oT4.y, r1, r3
dp3 oT5.y, r1, r4
mov oT2.xyz, -r0
dp3 oT3.z, v2, r2
dp3 oT3.x, r2, v1
dp3 oT4.z, v2, r3
dp3 oT4.x, v1, r3
dp3 oT5.z, v2, r4
dp3 oT5.x, v1, r4
mad oT0.xy, v3, c10, c10.zwzw
mad oT1.xy, v3, c11, c11.zwzw
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "xbox360 " {
Keywords { }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Vector 11 [_BumpMap_ST]
Vector 10 [_MainTex_ST]
Matrix 5 [_Object2World] 4
Vector 0 [_WorldSpaceCameraPos]
Matrix 1 [glstate_matrix_mvp] 4
Vector 9 [unity_Scale]
// Shader Timing Estimate, in Cycles/64 vertex vector:
// ALU: 37.33 (28 instructions), vertex: 32, texture: 0,
//   sequencer: 16,  9 GPRs, 21 threads,
// Performance (if enough threads): ~37 cycles per vector
// * Vertex cycle estimates are assuming 3 vfetch_minis for every vfetch_full,
//     with <= 32 bytes per vfetch_full group.

"vs_360
backbbabaaaaaboaaaaaablmaaaaaaaaaaaaaaceaaaaaaaaaaaaabgaaaaaaaaa
aaaaaaaaaaaaabdiaaaaaabmaaaaabckpppoadaaaaaaaaagaaaaaabmaaaaaaaa
aaaaabcdaaaaaajeaaacaaalaaabaaaaaaaaaakaaaaaaaaaaaaaaalaaaacaaak
aaabaaaaaaaaaakaaaaaaaaaaaaaaalmaaacaaafaaaeaaaaaaaaaammaaaaaaaa
aaaaaanmaaacaaaaaaabaaaaaaaaaapeaaaaaaaaaaaaabaeaaacaaabaaaeaaaa
aaaaaammaaaaaaaaaaaaabbhaaacaaajaaabaaaaaaaaaakaaaaaaaaafpechfgn
haengbhafpfdfeaaaaabaaadaaabaaaeaaabaaaaaaaaaaaafpengbgjgofegfhi
fpfdfeaafpepgcgkgfgdhedcfhgphcgmgeaaklklaaadaaadaaaeaaaeaaabaaaa
aaaaaaaafpfhgphcgmgefdhagbgdgfedgbgngfhcgbfagphdaaklklklaaabaaad
aaabaaadaaabaaaaaaaaaaaaghgmhdhegbhegffpgngbhehcgjhifpgnhghaaahf
gogjhehjfpfdgdgbgmgfaahghdfpddfpdaaadccodacodcdadddfddcodaaaklkl
aaaaaaaaaaaaablmaafbaaaiaaaaaaaaaaaaaaaaaaaaeamgaaaaaaabaaaaaaae
aaaaaaamaaaaacjaaabaaaaeaaaagaafaaaadaagaadafaahaaaadafaaaabdbfb
aaachcfcaaadhdfdaaaghefeaaajhfffaaaabaccaaaabacdaaaababiaaaaaabj
aaaaaabkaaaabablaaaaaabmaaaaaabnaaaababoaaaaaabpaaaaaacaaaaabacb
paffeaaeaaaabcaamcaaaaaaaaaaeaaiaaaabcaameaaaaaaaaaagaamgabcbcaa
bcaaaaaaaaaagabigabobcaaccaaaaaaafpihaaaaaaaaanbaaaaaaaaafpieaaa
aaaaagiiaaaaaaaaafpibaaaaaaaaoiiaaaaaaaaafpiaaaaaaaaapmiaaaaaaaa
miapaaacaamgiiaakbahaeaamiapaaacaalbiiaaklahadacmiapaaacaagmdeje
klahacacmiapiadoaablaadeklahabacmiabaaacaamgblaacbafajaamiacaaac
aamgblaacbagajaabeabaaafaalbblmgabafajahamecacafaalbblblabagajaj
beabaaagaagmbllbabafajahamecafagaagmblblabagajajbeahaaadaalogfgm
mbabaeahmiahaaaiabmgmamailahaiaamiahaaaiaalbmamaklahahaimiahaaad
abgflomaolabaeadamehagadaamablblmbadaeajmiahaaahaagmleleklahagai
miahiaacaablmaleklahafahmiabiaadaaloloaapaagaeaamiaciaadaaloloaa
paadagaamiaeiaadaaloloaapaagabaamiabiaaeaaloloaapaafaeaamiaciaae
aaloloaapaadafaamiaeiaaeaaloloaapaafabaamiabiaafaaloloaapaacaeaa
miaciaafaaloloaapaadacaamiaeiaafaaloloaapaacabaamiadiaaaaalalabk
ilaaakakmiadiaabaalalabkilaaalalaaaaaaaaaaaaaaaaaaaaaaaa"
}

SubProgram "ps3 " {
Keywords { }
Matrix 256 [glstate_matrix_mvp]
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Vector 467 [_WorldSpaceCameraPos]
Matrix 260 [_Object2World]
Vector 466 [unity_Scale]
Vector 465 [_MainTex_ST]
Vector 464 [_BumpMap_ST]
"sce_vp_rsx // 28 instructions using 6 registers
[Configuration]
8
0000001c41050600
[Microcode]
448
00009c6c00400e0c0106c0836041dffc401f9c6c011d1808010400d740619f9c
401f9c6c011d0808010400d740619fa0401f9c6c01d0300d8106c0c360403f80
401f9c6c01d0200d8106c0c360405f80401f9c6c01d0100d8106c0c360409f80
401f9c6c01d0000d8106c0c360411f8000001c6c005d207f8186c08360403ffc
00001c6c01d0600d8106c0c360405ffc00001c6c01d0500d8106c0c360409ffc
00001c6c01d0400d8106c0c360411ffc00001c6c00dd300c0186c0a30021dffc
00029c6c0090607f808600c36041dffc00021c6c0090507f808600c36041dffc
00019c6c0090407f808600c36041dffc00011c6c00800243011841436041dffc
00009c6c01000230812181630121dffc401f9c6c0140020c0106034360405fa8
401f9c6c01400e0c0686008360411fa8401f9c6c0140020c0106044360405fac
401f9c6c01400e0c0106044360411fac401f9c6c0140020c0106054360405fb0
401f9c6c01400e0c0106054360411fb0401f9c6c0040008c0086c0836041dfa4
00001c6c00800e0c02bfc0836041dffc401f9c6c0140000c0686004360409fa8
401f9c6c0140000c0086044360409fac401f9c6c0140000c0086054360409fb1
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 80 // 48 used size, 5 vars
Vector 16 [_MainTex_ST] 4
Vector 32 [_BumpMap_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 37 instructions, 2 temp regs, 0 temp arrays:
// ALU 27 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedclokhfaphmmlilnpghdmgnibbfcjimipabaaaaaalmagaaaaadaaaaaa
cmaaaaaamaaaaaaajaabaaaaejfdeheoimaaaaaaaeaaaaaaaiaaaaaagiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaahbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaahjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaaiaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaafaepfdej
feejepeoaafeebeoehefeofeaaeoepfcenebemaafeeffiedepepfceeaaklklkl
epfdeheomiaaaaaaahaaaaaaaiaaaaaalaaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaalmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaa
lmaaaaaaabaaaaaaaaaaaaaaadaaaaaaabaaaaaaamadaaaalmaaaaaaacaaaaaa
aaaaaaaaadaaaaaaacaaaaaaahaiaaaalmaaaaaaadaaaaaaaaaaaaaaadaaaaaa
adaaaaaaahaiaaaalmaaaaaaaeaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaa
lmaaaaaaafaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfaepfdejfe
ejepeoaafeeffiedepepfceeaaklklklfdeieefcceafaaaaeaaaabaaejabaaaa
fjaaaaaeegiocaaaaaaaaaaaadaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaa
fjaaaaaeegiocaaaacaaaaaabfaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaad
pcbabaaaabaaaaaafpaaaaadhcbabaaaacaaaaaafpaaaaaddcbabaaaadaaaaaa
ghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaaabaaaaaagfaaaaad
mccabaaaabaaaaaagfaaaaadhccabaaaacaaaaaagfaaaaadhccabaaaadaaaaaa
gfaaaaadhccabaaaaeaaaaaagfaaaaadhccabaaaafaaaaaagiaaaaacacaaaaaa
diaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaabaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaaaaaaaaaagbabaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaacaaaaaa
kgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaa
acaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaaldccabaaa
abaaaaaaegbabaaaadaaaaaaegiacaaaaaaaaaaaabaaaaaaogikcaaaaaaaaaaa
abaaaaaadcaaaaalmccabaaaabaaaaaaagbebaaaadaaaaaaagiecaaaaaaaaaaa
acaaaaaakgiocaaaaaaaaaaaacaaaaaadiaaaaaihcaabaaaaaaaaaaafgbfbaaa
aaaaaaaaegiccaaaacaaaaaaanaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaa
acaaaaaaamaaaaaaagbabaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaa
aaaaaaaaegiccaaaacaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaaaaaaaaa
dcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaapaaaaaapgbpbaaaaaaaaaaa
egacbaaaaaaaaaaaaaaaaaajhcaabaaaaaaaaaaaegacbaiaebaaaaaaaaaaaaaa
egiccaaaabaaaaaaaeaaaaaadgaaaaaghccabaaaacaaaaaaegacbaiaebaaaaaa
aaaaaaaadgaaaaagbcaabaaaaaaaaaaaakiacaaaacaaaaaaamaaaaaadgaaaaag
ccaabaaaaaaaaaaaakiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaaaaaaaaaa
akiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaaaaaaaaaa
pgipcaaaacaaaaaabeaaaaaabaaaaaahbccabaaaadaaaaaaegbcbaaaabaaaaaa
egacbaaaaaaaaaaabaaaaaaheccabaaaadaaaaaaegbcbaaaacaaaaaaegacbaaa
aaaaaaaadiaaaaahhcaabaaaabaaaaaajgbebaaaabaaaaaacgbjbaaaacaaaaaa
dcaaaaakhcaabaaaabaaaaaajgbebaaaacaaaaaacgbjbaaaabaaaaaaegacbaia
ebaaaaaaabaaaaaadiaaaaahhcaabaaaabaaaaaaegacbaaaabaaaaaapgbpbaaa
abaaaaaabaaaaaahcccabaaaadaaaaaaegacbaaaabaaaaaaegacbaaaaaaaaaaa
dgaaaaagbcaabaaaaaaaaaaabkiacaaaacaaaaaaamaaaaaadgaaaaagccaabaaa
aaaaaaaabkiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaaaaaaaaaabkiacaaa
acaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaaaaaaaaaapgipcaaa
acaaaaaabeaaaaaabaaaaaahcccabaaaaeaaaaaaegacbaaaabaaaaaaegacbaaa
aaaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaaabaaaaaaegacbaaaaaaaaaaa
baaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaadgaaaaag
bcaabaaaaaaaaaaackiacaaaacaaaaaaamaaaaaadgaaaaagccaabaaaaaaaaaaa
ckiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaaaaaaaaaackiacaaaacaaaaaa
aoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaaaaaaaaaapgipcaaaacaaaaaa
beaaaaaabaaaaaahcccabaaaafaaaaaaegacbaaaabaaaaaaegacbaaaaaaaaaaa
baaaaaahbccabaaaafaaaaaaegbcbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaah
eccabaaaafaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec3 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _BumpMap_ST;
uniform highp vec4 _MainTex_ST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  highp vec3 tmpvar_3;
  highp vec3 tmpvar_4;
  tmpvar_3 = tmpvar_1.xyz;
  tmpvar_4 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_5;
  tmpvar_5[0].x = tmpvar_3.x;
  tmpvar_5[0].y = tmpvar_4.x;
  tmpvar_5[0].z = tmpvar_2.x;
  tmpvar_5[1].x = tmpvar_3.y;
  tmpvar_5[1].y = tmpvar_4.y;
  tmpvar_5[1].z = tmpvar_2.y;
  tmpvar_5[2].x = tmpvar_3.z;
  tmpvar_5[2].y = tmpvar_4.z;
  tmpvar_5[2].z = tmpvar_2.z;
  vec4 v_6;
  v_6.x = _Object2World[0].x;
  v_6.y = _Object2World[1].x;
  v_6.z = _Object2World[2].x;
  v_6.w = _Object2World[3].x;
  vec4 v_7;
  v_7.x = _Object2World[0].y;
  v_7.y = _Object2World[1].y;
  v_7.z = _Object2World[2].y;
  v_7.w = _Object2World[3].y;
  vec4 v_8;
  v_8.x = _Object2World[0].z;
  v_8.y = _Object2World[1].z;
  v_8.z = _Object2World[2].z;
  v_8.w = _Object2World[3].z;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = ((_glesMultiTexCoord0.xy * _BumpMap_ST.xy) + _BumpMap_ST.zw);
  xlv_TEXCOORD2 = ((_Object2World * _glesVertex).xyz - _WorldSpaceCameraPos);
  xlv_TEXCOORD3 = (tmpvar_5 * (v_6.xyz * unity_Scale.w));
  xlv_TEXCOORD4 = (tmpvar_5 * (v_7.xyz * unity_Scale.w));
  xlv_TEXCOORD5 = (tmpvar_5 * (v_8.xyz * unity_Scale.w));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform lowp vec4 _ReflectColor;
uniform samplerCube _Cube;
uniform sampler2D _MainTex;
uniform sampler2D _BumpMap;
uniform highp vec4 glstate_lightmodel_ambient;
void main ()
{
  lowp vec4 c_1;
  mediump vec3 r_2;
  mediump vec3 wn_3;
  lowp vec3 tmpvar_4;
  tmpvar_4 = ((texture2D (_BumpMap, xlv_TEXCOORD1).xyz * 2.0) - 1.0);
  lowp vec4 tmpvar_5;
  tmpvar_5 = texture2D (_MainTex, xlv_TEXCOORD0);
  highp float tmpvar_6;
  tmpvar_6 = dot (xlv_TEXCOORD3, tmpvar_4);
  wn_3.x = tmpvar_6;
  highp float tmpvar_7;
  tmpvar_7 = dot (xlv_TEXCOORD4, tmpvar_4);
  wn_3.y = tmpvar_7;
  highp float tmpvar_8;
  tmpvar_8 = dot (xlv_TEXCOORD5, tmpvar_4);
  wn_3.z = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (xlv_TEXCOORD2 - (2.0 * (dot (wn_3, xlv_TEXCOORD2) * wn_3)));
  r_2 = tmpvar_9;
  highp vec4 tmpvar_10;
  tmpvar_10 = (glstate_lightmodel_ambient * tmpvar_5);
  c_1 = tmpvar_10;
  c_1.xyz = (c_1.xyz * 2.0);
  gl_FragData[0] = (c_1 + ((textureCube (_Cube, r_2) * _ReflectColor) * tmpvar_5.w));
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec3 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _BumpMap_ST;
uniform highp vec4 _MainTex_ST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  highp vec3 tmpvar_3;
  highp vec3 tmpvar_4;
  tmpvar_3 = tmpvar_1.xyz;
  tmpvar_4 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_5;
  tmpvar_5[0].x = tmpvar_3.x;
  tmpvar_5[0].y = tmpvar_4.x;
  tmpvar_5[0].z = tmpvar_2.x;
  tmpvar_5[1].x = tmpvar_3.y;
  tmpvar_5[1].y = tmpvar_4.y;
  tmpvar_5[1].z = tmpvar_2.y;
  tmpvar_5[2].x = tmpvar_3.z;
  tmpvar_5[2].y = tmpvar_4.z;
  tmpvar_5[2].z = tmpvar_2.z;
  vec4 v_6;
  v_6.x = _Object2World[0].x;
  v_6.y = _Object2World[1].x;
  v_6.z = _Object2World[2].x;
  v_6.w = _Object2World[3].x;
  vec4 v_7;
  v_7.x = _Object2World[0].y;
  v_7.y = _Object2World[1].y;
  v_7.z = _Object2World[2].y;
  v_7.w = _Object2World[3].y;
  vec4 v_8;
  v_8.x = _Object2World[0].z;
  v_8.y = _Object2World[1].z;
  v_8.z = _Object2World[2].z;
  v_8.w = _Object2World[3].z;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = ((_glesMultiTexCoord0.xy * _BumpMap_ST.xy) + _BumpMap_ST.zw);
  xlv_TEXCOORD2 = ((_Object2World * _glesVertex).xyz - _WorldSpaceCameraPos);
  xlv_TEXCOORD3 = (tmpvar_5 * (v_6.xyz * unity_Scale.w));
  xlv_TEXCOORD4 = (tmpvar_5 * (v_7.xyz * unity_Scale.w));
  xlv_TEXCOORD5 = (tmpvar_5 * (v_8.xyz * unity_Scale.w));
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD5;
varying highp vec3 xlv_TEXCOORD4;
varying highp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform lowp vec4 _ReflectColor;
uniform samplerCube _Cube;
uniform sampler2D _MainTex;
uniform sampler2D _BumpMap;
uniform highp vec4 glstate_lightmodel_ambient;
void main ()
{
  lowp vec4 c_1;
  mediump vec3 r_2;
  mediump vec3 wn_3;
  lowp vec3 normal_4;
  normal_4.xy = ((texture2D (_BumpMap, xlv_TEXCOORD1).wy * 2.0) - 1.0);
  normal_4.z = sqrt((1.0 - clamp (dot (normal_4.xy, normal_4.xy), 0.0, 1.0)));
  lowp vec4 tmpvar_5;
  tmpvar_5 = texture2D (_MainTex, xlv_TEXCOORD0);
  highp float tmpvar_6;
  tmpvar_6 = dot (xlv_TEXCOORD3, normal_4);
  wn_3.x = tmpvar_6;
  highp float tmpvar_7;
  tmpvar_7 = dot (xlv_TEXCOORD4, normal_4);
  wn_3.y = tmpvar_7;
  highp float tmpvar_8;
  tmpvar_8 = dot (xlv_TEXCOORD5, normal_4);
  wn_3.z = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = (xlv_TEXCOORD2 - (2.0 * (dot (wn_3, xlv_TEXCOORD2) * wn_3)));
  r_2 = tmpvar_9;
  highp vec4 tmpvar_10;
  tmpvar_10 = (glstate_lightmodel_ambient * tmpvar_5);
  c_1 = tmpvar_10;
  c_1.xyz = (c_1.xyz * 2.0);
  gl_FragData[0] = (c_1 + ((textureCube (_Cube, r_2) * _ReflectColor) * tmpvar_5.w));
}



#endif"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [_MainTex_ST]
Vector 11 [_BumpMap_ST]
"agal_vs
[bc]
aaaaaaaaaaaaahacafaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, a5
adaaaaaaabaaahacabaaaancaaaaaaaaaaaaaaajacaaaaaa mul r1.xyz, a1.zxyw, r0.yzxx
aaaaaaaaaaaaahacafaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, a5
adaaaaaaacaaahacabaaaamjaaaaaaaaaaaaaafcacaaaaaa mul r2.xyz, a1.yzxw, r0.zxyy
acaaaaaaaaaaahacacaaaakeacaaaaaaabaaaakeacaaaaaa sub r0.xyz, r2.xyzz, r1.xyzz
adaaaaaaabaaahacaaaaaakeacaaaaaaafaaaappaaaaaaaa mul r1.xyz, r0.xyzz, a5.w
aaaaaaaaaaaaahacafaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, c5
adaaaaaaadaaahacajaaaappabaaaaaaaaaaaakeacaaaaaa mul r3.xyz, c9.w, r0.xyzz
aaaaaaaaaaaaahacagaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, c6
adaaaaaaaeaaahacajaaaappabaaaaaaaaaaaakeacaaaaaa mul r4.xyz, c9.w, r0.xyzz
aaaaaaaaacaaahacaeaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r2.xyz, c4
adaaaaaaacaaahacajaaaappabaaaaaaacaaaakeacaaaaaa mul r2.xyz, c9.w, r2.xyzz
bdaaaaaaaaaaaeacaaaaaaoeaaaaaaaaagaaaaoeabaaaaaa dp4 r0.z, a0, c6
bdaaaaaaaaaaabacaaaaaaoeaaaaaaaaaeaaaaoeabaaaaaa dp4 r0.x, a0, c4
bdaaaaaaaaaaacacaaaaaaoeaaaaaaaaafaaaaoeabaaaaaa dp4 r0.y, a0, c5
bfaaaaaaaaaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r0.xyz, r0.xyzz
abaaaaaaaaaaahacaaaaaakeacaaaaaaaiaaaaoeabaaaaaa add r0.xyz, r0.xyzz, c8
bcaaaaaaadaaacaeacaaaakeacaaaaaaabaaaakeacaaaaaa dp3 v3.y, r2.xyzz, r1.xyzz
bcaaaaaaaeaaacaeabaaaakeacaaaaaaadaaaakeacaaaaaa dp3 v4.y, r1.xyzz, r3.xyzz
bcaaaaaaafaaacaeabaaaakeacaaaaaaaeaaaakeacaaaaaa dp3 v5.y, r1.xyzz, r4.xyzz
bfaaaaaaacaaahaeaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg v2.xyz, r0.xyzz
bcaaaaaaadaaaeaeabaaaaoeaaaaaaaaacaaaakeacaaaaaa dp3 v3.z, a1, r2.xyzz
bcaaaaaaadaaabaeacaaaakeacaaaaaaafaaaaoeaaaaaaaa dp3 v3.x, r2.xyzz, a5
bcaaaaaaaeaaaeaeabaaaaoeaaaaaaaaadaaaakeacaaaaaa dp3 v4.z, a1, r3.xyzz
bcaaaaaaaeaaabaeafaaaaoeaaaaaaaaadaaaakeacaaaaaa dp3 v4.x, a5, r3.xyzz
bcaaaaaaafaaaeaeabaaaaoeaaaaaaaaaeaaaakeacaaaaaa dp3 v5.z, a1, r4.xyzz
bcaaaaaaafaaabaeafaaaaoeaaaaaaaaaeaaaakeacaaaaaa dp3 v5.x, a5, r4.xyzz
adaaaaaaaaaaadacadaaaaoeaaaaaaaaakaaaaoeabaaaaaa mul r0.xy, a3, c10
abaaaaaaaaaaadaeaaaaaafeacaaaaaaakaaaaooabaaaaaa add v0.xy, r0.xyyy, c10.zwzw
adaaaaaaaaaaadacadaaaaoeaaaaaaaaalaaaaoeabaaaaaa mul r0.xy, a3, c11
abaaaaaaabaaadaeaaaaaafeacaaaaaaalaaaaooabaaaaaa add v1.xy, r0.xyyy, c11.zwzw
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaaaaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c0
aaaaaaaaabaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v1.zw, c0
aaaaaaaaacaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v2.w, c0
aaaaaaaaadaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v3.w, c0
aaaaaaaaaeaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v4.w, c0
aaaaaaaaafaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v5.w, c0
"
}

SubProgram "d3d11_9x " {
Keywords { }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 80 // 48 used size, 5 vars
Vector 16 [_MainTex_ST] 4
Vector 32 [_BumpMap_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 37 instructions, 2 temp regs, 0 temp arrays:
// ALU 27 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_1
eefiecedljjefnilohoibdkinkamfpimdnekllhcabaaaaaammajaaaaaeaaaaaa
daaaaaaadmadaaaagiaiaaaapmaiaaaaebgpgodjaeadaaaaaeadaaaaaaacpopp
kaacaaaageaaaaaaafaaceaaaaaagaaaaaaagaaaaaaaceaaabaagaaaaaaaabaa
acaaabaaaaaaaaaaabaaaeaaabaaadaaaaaaaaaaacaaaaaaaeaaaeaaaaaaaaaa
acaaamaaaeaaaiaaaaaaaaaaacaabeaaabaaamaaaaaaaaaaaaaaaaaaaaacpopp
bpaaaaacafaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjabpaaaaacafaaacia
acaaapjabpaaaaacafaaadiaadaaapjaaeaaaaaeaaaaadoaadaaoejaabaaoeka
abaaookaaeaaaaaeaaaaamoaadaabejaacaabekaacaalekaafaaaaadaaaaahia
aaaaffjaajaaoekaaeaaaaaeaaaaahiaaiaaoekaaaaaaajaaaaaoeiaaeaaaaae
aaaaahiaakaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaahiaalaaoekaaaaappja
aaaaoeiaacaaaaadaaaaahiaaaaaoeibadaaoekaabaaaaacabaaahoaaaaaoeib
abaaaaacaaaaabiaaiaaaakaabaaaaacaaaaaciaajaaaakaabaaaaacaaaaaeia
akaaaakaafaaaaadaaaaahiaaaaaoeiaamaappkaaiaaaaadacaaaboaabaaoeja
aaaaoeiaabaaaaacabaaahiaabaaoejaafaaaaadacaaahiaabaamjiaacaancja
aeaaaaaeabaaahiaacaamjjaabaanciaacaaoeibafaaaaadabaaahiaabaaoeia
abaappjaaiaaaaadacaaacoaabaaoeiaaaaaoeiaaiaaaaadacaaaeoaacaaoeja
aaaaoeiaabaaaaacaaaaabiaaiaaffkaabaaaaacaaaaaciaajaaffkaabaaaaac
aaaaaeiaakaaffkaafaaaaadaaaaahiaaaaaoeiaamaappkaaiaaaaadadaaaboa
abaaoejaaaaaoeiaaiaaaaadadaaacoaabaaoeiaaaaaoeiaaiaaaaadadaaaeoa
acaaoejaaaaaoeiaabaaaaacaaaaabiaaiaakkkaabaaaaacaaaaaciaajaakkka
abaaaaacaaaaaeiaakaakkkaafaaaaadaaaaahiaaaaaoeiaamaappkaaiaaaaad
aeaaaboaabaaoejaaaaaoeiaaiaaaaadaeaaacoaabaaoeiaaaaaoeiaaiaaaaad
aeaaaeoaacaaoejaaaaaoeiaafaaaaadaaaaapiaaaaaffjaafaaoekaaeaaaaae
aaaaapiaaeaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaagaaoekaaaaakkja
aaaaoeiaaeaaaaaeaaaaapiaahaaoekaaaaappjaaaaaoeiaaeaaaaaeaaaaadma
aaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiappppaaaafdeieefc
ceafaaaaeaaaabaaejabaaaafjaaaaaeegiocaaaaaaaaaaaadaaaaaafjaaaaae
egiocaaaabaaaaaaafaaaaaafjaaaaaeegiocaaaacaaaaaabfaaaaaafpaaaaad
pcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaadhcbabaaaacaaaaaa
fpaaaaaddcbabaaaadaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaad
dccabaaaabaaaaaagfaaaaadmccabaaaabaaaaaagfaaaaadhccabaaaacaaaaaa
gfaaaaadhccabaaaadaaaaaagfaaaaadhccabaaaaeaaaaaagfaaaaadhccabaaa
afaaaaaagiaaaaacacaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaa
egiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaa
aaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pccabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaaldccabaaaabaaaaaaegbabaaaadaaaaaaegiacaaaaaaaaaaa
abaaaaaaogikcaaaaaaaaaaaabaaaaaadcaaaaalmccabaaaabaaaaaaagbebaaa
adaaaaaaagiecaaaaaaaaaaaacaaaaaakgiocaaaaaaaaaaaacaaaaaadiaaaaai
hcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiccaaaacaaaaaaanaaaaaadcaaaaak
hcaabaaaaaaaaaaaegiccaaaacaaaaaaamaaaaaaagbabaaaaaaaaaaaegacbaaa
aaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaaoaaaaaakgbkbaaa
aaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaa
apaaaaaapgbpbaaaaaaaaaaaegacbaaaaaaaaaaaaaaaaaajhcaabaaaaaaaaaaa
egacbaiaebaaaaaaaaaaaaaaegiccaaaabaaaaaaaeaaaaaadgaaaaaghccabaaa
acaaaaaaegacbaiaebaaaaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaaakiacaaa
acaaaaaaamaaaaaadgaaaaagccaabaaaaaaaaaaaakiacaaaacaaaaaaanaaaaaa
dgaaaaagecaabaaaaaaaaaaaakiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaa
aaaaaaaaegacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahbccabaaa
adaaaaaaegbcbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaadaaaaaa
egbcbaaaacaaaaaaegacbaaaaaaaaaaadiaaaaahhcaabaaaabaaaaaajgbebaaa
abaaaaaacgbjbaaaacaaaaaadcaaaaakhcaabaaaabaaaaaajgbebaaaacaaaaaa
cgbjbaaaabaaaaaaegacbaiaebaaaaaaabaaaaaadiaaaaahhcaabaaaabaaaaaa
egacbaaaabaaaaaapgbpbaaaabaaaaaabaaaaaahcccabaaaadaaaaaaegacbaaa
abaaaaaaegacbaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaabkiacaaaacaaaaaa
amaaaaaadgaaaaagccaabaaaaaaaaaaabkiacaaaacaaaaaaanaaaaaadgaaaaag
ecaabaaaaaaaaaaabkiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaa
egacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaaaeaaaaaa
egacbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaa
abaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaa
egacbaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaackiacaaaacaaaaaaamaaaaaa
dgaaaaagccaabaaaaaaaaaaackiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaa
aaaaaaaackiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaa
aaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaaafaaaaaaegacbaaa
abaaaaaaegacbaaaaaaaaaaabaaaaaahbccabaaaafaaaaaaegbcbaaaabaaaaaa
egacbaaaaaaaaaaabaaaaaaheccabaaaafaaaaaaegbcbaaaacaaaaaaegacbaaa
aaaaaaaadoaaaaabejfdeheoimaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaaaaaaaaaapapaaaahbaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaapapaaaahjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaahahaaaa
iaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaafaepfdejfeejepeo
aafeebeoehefeofeaaeoepfcenebemaafeeffiedepepfceeaaklklklepfdeheo
miaaaaaaahaaaaaaaiaaaaaalaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaalmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaalmaaaaaa
abaaaaaaaaaaaaaaadaaaaaaabaaaaaaamadaaaalmaaaaaaacaaaaaaaaaaaaaa
adaaaaaaacaaaaaaahaiaaaalmaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaa
ahaiaaaalmaaaaaaaeaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaalmaaaaaa
afaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfaepfdejfeejepeoaa
feeffiedepepfceeaaklklkl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
vec2 xll_matrixindex_mf2x2_i (mat2 m, int i) { vec2 v; v.x=m[0][i]; v.y=m[1][i]; return v; }
vec3 xll_matrixindex_mf3x3_i (mat3 m, int i) { vec3 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; return v; }
vec4 xll_matrixindex_mf4x4_i (mat4 m, int i) { vec4 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; v.w=m[3][i]; return v; }
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct v2f {
    highp vec4 pos;
    highp vec2 uv;
    highp vec2 uv2;
    highp vec3 I;
    highp vec3 TtoW0;
    highp vec3 TtoW1;
    highp vec3 TtoW2;
};
#line 59
struct appdata_tan {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 326
uniform highp vec4 _MainTex_ST;
uniform highp vec4 _BumpMap_ST;
uniform sampler2D _BumpMap;
#line 342
uniform sampler2D _MainTex;
uniform samplerCube _Cube;
uniform lowp vec4 _ReflectColor;
uniform lowp vec4 _Color;
#line 346
#line 87
highp vec3 WorldSpaceViewDir( in highp vec4 v ) {
    return (_WorldSpaceCameraPos.xyz - (_Object2World * v).xyz);
}
#line 327
v2f vert( in appdata_tan v ) {
    v2f o;
    #line 330
    o.pos = (glstate_matrix_mvp * v.vertex);
    o.uv = ((v.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
    o.uv2 = ((v.texcoord.xy * _BumpMap_ST.xy) + _BumpMap_ST.zw);
    o.I = (-WorldSpaceViewDir( v.vertex));
    #line 334
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    o.TtoW0 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 0).xyz * unity_Scale.w));
    o.TtoW1 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 1).xyz * unity_Scale.w));
    #line 338
    o.TtoW2 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 2).xyz * unity_Scale.w));
    return o;
}

out highp vec2 xlv_TEXCOORD0;
out highp vec2 xlv_TEXCOORD1;
out highp vec3 xlv_TEXCOORD2;
out highp vec3 xlv_TEXCOORD3;
out highp vec3 xlv_TEXCOORD4;
out highp vec3 xlv_TEXCOORD5;
void main() {
    v2f xl_retval;
    appdata_tan xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xl_retval = vert( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec2(xl_retval.uv);
    xlv_TEXCOORD1 = vec2(xl_retval.uv2);
    xlv_TEXCOORD2 = vec3(xl_retval.I);
    xlv_TEXCOORD3 = vec3(xl_retval.TtoW0);
    xlv_TEXCOORD4 = vec3(xl_retval.TtoW1);
    xlv_TEXCOORD5 = vec3(xl_retval.TtoW2);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct v2f {
    highp vec4 pos;
    highp vec2 uv;
    highp vec2 uv2;
    highp vec3 I;
    highp vec3 TtoW0;
    highp vec3 TtoW1;
    highp vec3 TtoW2;
};
#line 59
struct appdata_tan {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 326
uniform highp vec4 _MainTex_ST;
uniform highp vec4 _BumpMap_ST;
uniform sampler2D _BumpMap;
#line 342
uniform sampler2D _MainTex;
uniform samplerCube _Cube;
uniform lowp vec4 _ReflectColor;
uniform lowp vec4 _Color;
#line 346
#line 272
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 274
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 346
lowp vec4 frag( in v2f i ) {
    lowp vec3 normal = UnpackNormal( texture( _BumpMap, i.uv2));
    lowp vec4 texcol = texture( _MainTex, i.uv);
    #line 350
    mediump vec3 wn;
    wn.x = dot( i.TtoW0, normal);
    wn.y = dot( i.TtoW1, normal);
    wn.z = dot( i.TtoW2, normal);
    #line 354
    mediump vec3 r = reflect( i.I, wn);
    lowp vec4 c = (glstate_lightmodel_ambient * texcol);
    c.xyz *= 2.0;
    lowp vec4 reflcolor = ((texture( _Cube, r) * _ReflectColor) * texcol.w);
    #line 358
    return (c + reflcolor);
}
in highp vec2 xlv_TEXCOORD0;
in highp vec2 xlv_TEXCOORD1;
in highp vec3 xlv_TEXCOORD2;
in highp vec3 xlv_TEXCOORD3;
in highp vec3 xlv_TEXCOORD4;
in highp vec3 xlv_TEXCOORD5;
void main() {
    lowp vec4 xl_retval;
    v2f xlt_i;
    xlt_i.pos = vec4(0.0);
    xlt_i.uv = vec2(xlv_TEXCOORD0);
    xlt_i.uv2 = vec2(xlv_TEXCOORD1);
    xlt_i.I = vec3(xlv_TEXCOORD2);
    xlt_i.TtoW0 = vec3(xlv_TEXCOORD3);
    xlt_i.TtoW1 = vec3(xlv_TEXCOORD4);
    xlt_i.TtoW2 = vec3(xlv_TEXCOORD5);
    xl_retval = frag( xlt_i);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 21 to 21, TEX: 3 to 3
//   d3d9 - ALU: 20 to 20, TEX: 3 to 3
//   d3d11 - ALU: 15 to 15, TEX: 3 to 3, FLOW: 1 to 1
//   d3d11_9x - ALU: 15 to 15, TEX: 3 to 3, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 1 [_ReflectColor]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
"!!ARBfp1.0
# 21 ALU, 3 TEX
PARAM c[3] = { state.lightmodel.ambient,
		program.local[1],
		{ 2, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEX R0.yw, fragment.texcoord[1], texture[0], 2D;
MAD R0.xy, R0.wyzw, c[2].x, -c[2].y;
MUL R0.zw, R0.xyxy, R0.xyxy;
ADD_SAT R0.z, R0, R0.w;
ADD R0.z, -R0, c[2].y;
RSQ R0.z, R0.z;
RCP R0.z, R0.z;
DP3 R1.z, fragment.texcoord[5], R0;
DP3 R1.x, R0, fragment.texcoord[3];
DP3 R1.y, R0, fragment.texcoord[4];
DP3 R0.x, R1, fragment.texcoord[2];
MUL R0.xyz, R1, R0.x;
MAD R0.xyz, -R0, c[2].x, fragment.texcoord[2];
TEX R1, R0, texture[2], CUBE;
TEX R0, fragment.texcoord[0], texture[1], 2D;
MUL R1, R1, c[1];
MUL R2, R0, c[0];
MUL R0, R0.w, R1;
MUL R1.xyz, R2, c[2].x;
MOV R1.w, R2;
ADD result.color, R1, R0;
END
# 21 instructions, 3 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [glstate_lightmodel_ambient]
Vector 1 [_ReflectColor]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
"ps_2_0
; 20 ALU, 3 TEX
dcl_2d s0
dcl_2d s1
dcl_cube s2
def c2, 2.00000000, -1.00000000, 1.00000000, 0
dcl t0.xy
dcl t1.xy
dcl t2.xyz
dcl t3.xyz
dcl t4.xyz
dcl t5.xyz
texld r0, t1, s0
mov r0.x, r0.w
mad_pp r0.xy, r0, c2.x, c2.y
mul_pp r1.xy, r0, r0
add_pp_sat r1.x, r1, r1.y
add_pp r1.x, -r1, c2.z
rsq_pp r1.x, r1.x
rcp_pp r0.z, r1.x
dp3 r1.z, t5, r0
dp3 r1.x, r0, t3
dp3 r1.y, r0, t4
dp3 r0.x, r1, t2
mul r0.xyz, r1, r0.x
mad r0.xyz, -r0, c2.x, t2
texld r1, r0, s2
texld r0, t0, s1
mul r1, r1, c1
mul r2, r0, c0
mul r0, r0.w, r1
mul_pp r1.xyz, r2, c2.x
mov_pp r1.w, r2
add_pp r0, r1, r0
mov_pp oC0, r0
"
}

SubProgram "xbox360 " {
Keywords { }
Vector 1 [_ReflectColor]
Vector 0 [glstate_lightmodel_ambient]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
// Shader Timing Estimate, in Cycles/64 pixel vector:
// ALU: 22.67 (17 instructions), vertex: 0, texture: 12,
//   sequencer: 10, interpolator: 24;    7 GPRs, 27 threads,
// Performance (if enough threads): ~24 cycles per vector
// * Texture cycle estimates are assuming an 8bit/component texture with no
//     aniso or trilinear filtering.

"ps_360
backbbaaaaaaabjeaaaaabgaaaaaaaaaaaaaaaceaaaaabdeaaaaabfmaaaaaaaa
aaaaaaaaaaaaabamaaaaaabmaaaaaapoppppadaaaaaaaaafaaaaaabmaaaaaaaa
aaaaaaphaaaaaaiaaaadaaaaaaabaaaaaaaaaaimaaaaaaaaaaaaaajmaaadaaac
aaabaaaaaaaaaakeaaaaaaaaaaaaaaleaaadaaabaaabaaaaaaaaaaimaaaaaaaa
aaaaaalnaaacaaabaaabaaaaaaaaaammaaaaaaaaaaaaaanmaaacaaaaaaabaaaa
aaaaaammaaaaaaaafpechfgnhaengbhaaaklklklaaaeaaamaaabaaabaaabaaaa
aaaaaaaafpedhfgcgfaaklklaaaeaaaoaaabaaabaaabaaaaaaaaaaaafpengbgj
gofegfhiaafpfcgfgggmgfgdheedgpgmgphcaaklaaabaaadaaabaaaeaaabaaaa
aaaaaaaaghgmhdhegbhegffpgmgjghgihegngpgegfgmfpgbgngcgjgfgoheaaha
hdfpddfpdaaadccodacodcdadddfddcodaaaklklaaaaaaaaaaaaaaabaaaaaaaa
aaaaaaaaaaaaaabeabpmaabaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaea
aaaaabcabaaaagaaaaaaaaaeaaaaaaaaaaaaeamgaadpaadpaaaaaaabaaaadafa
aaaadbfbaaaahcfcaaaahdfdaaaahefeaaaahfffaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeaaaaaaaaaaaaaaalpiaaaaa
dpmaaaaadpiaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaajgaadgaajbcaabcaaaaaa
aafaeaapaaaabcaameaaaaaaaaaaeabdaaaaccaaaaaaaaaabaaaaacbbpbppghp
aaaaeaaamiadaaagaamhgmmgilaapopomjaeaaaaaalalalbnbagagpolieaaaaa
aaaaaaecmcaaaappkaeaagaaaaaaaamgocaaaaiamiabaaabaaloloaapaagadaa
miacaaabaaloloaapaagaeaamiaeaaabaaloloaapaagafaamiaeaaaaaaloloaa
paabacaaaaeaaaaaaaaaaamgocaaaaaamiahaaabaemgmamaolaaabacmiapaaab
aakgmnaapcababaaemeeaaacaablblmgocababibmiadaaacaagnmgblmlabaapo
jacicaebbpbppgiiaaaamaaababiaaabbpbppefiaaaaeaaamiahaaabaabebeaa
oaaaaaaabebpaaacaaaaaalbkbacabaakiihababaamamaaaibabaaaamiapiaaa
aaaalbaaolacaaabaaaaaaaaaaaaaaaaaaaaaaaa"
}

SubProgram "ps3 " {
Keywords { }
Vector 0 [glstate_lightmodel_ambient]
Vector 1 [_ReflectColor]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
"sce_fp_rsx // 21 instructions using 2 registers
[Configuration]
24
ffffffff000fc020003fffc3000000000000840002000000
[Offsets]
2
glstate.lightmodel.ambient 1 0
000000f0
_ReflectColor 1 0
00000120
[Microcode]
336
b4001700c8011c9dc8000001c8003fe106820440ce001c9d00020000aa020000
000040000000bf8000000000000000000280b840c9041c9dc9040001c8000001
02800340c9001c9f00020000c800000100003f80000000000000000000000000
08823b4001003c9cc9000001c800000128800501c8011c9dc9040001c8003fe1
04800501c9041c9dc8010001c8003fe1e2800500c9041c9dc8010001c8003fe1
ce020100c8011c9dc8000001c8003fe108000500c9001c9dc8041001c8000001
0e020400c9001c9f54000001c80400019e001702c8011c9dc8000001c8003fe1
1e800200c8001c9dc8020001c800000100000000000000000000000000000000
1e021704c8041c9dc8000001c80000011e840200c8041c9dc8020001c8000001
000000000000000000000000000000000e800140c9001c9dc8001001c8000001
1e810440c9081c9dfe000001c9000001
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 80 // 64 used size, 5 vars
Vector 48 [_ReflectColor] 4
ConstBuffer "UnityPerFrame" 208 // 80 used size, 4 vars
Vector 64 [glstate_lightmodel_ambient] 4
BindCB "$Globals" 0
BindCB "UnityPerFrame" 1
SetTexture 0 [_BumpMap] 2D 0
SetTexture 1 [_MainTex] 2D 1
SetTexture 2 [_Cube] CUBE 2
// 19 instructions, 2 temp regs, 0 temp arrays:
// ALU 15 float, 0 int, 0 uint
// TEX 3 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedgnfpecndfcmbamajndolnfgogcfdhfjcabaaaaaagiaeaaaaadaaaaaa
cmaaaaaapmaaaaaadaabaaaaejfdeheomiaaaaaaahaaaaaaaiaaaaaalaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaalmaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaalmaaaaaaabaaaaaaaaaaaaaaadaaaaaaabaaaaaa
amamaaaalmaaaaaaacaaaaaaaaaaaaaaadaaaaaaacaaaaaaahahaaaalmaaaaaa
adaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaalmaaaaaaaeaaaaaaaaaaaaaa
adaaaaaaaeaaaaaaahahaaaalmaaaaaaafaaaaaaaaaaaaaaadaaaaaaafaaaaaa
ahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklklepfdeheo
cmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaa
apaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcdaadaaaaeaaaaaaammaaaaaa
fjaaaaaeegiocaaaaaaaaaaaaeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaa
fkaaaaadaagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaafkaaaaadaagabaaa
acaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaa
ffffaaaafidaaaaeaahabaaaacaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaa
gcbaaaadmcbabaaaabaaaaaagcbaaaadhcbabaaaacaaaaaagcbaaaadhcbabaaa
adaaaaaagcbaaaadhcbabaaaaeaaaaaagcbaaaadhcbabaaaafaaaaaagfaaaaad
pccabaaaaaaaaaaagiaaaaacacaaaaaaefaaaaajpcaabaaaaaaaaaaaogbkbaaa
abaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaadcaaaaapdcaabaaaaaaaaaaa
hgapbaaaaaaaaaaaaceaaaaaaaaaaaeaaaaaaaeaaaaaaaaaaaaaaaaaaceaaaaa
aaaaialpaaaaialpaaaaaaaaaaaaaaaaapaaaaahicaabaaaaaaaaaaaegaabaaa
aaaaaaaaegaabaaaaaaaaaaaddaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaa
abeaaaaaaaaaiadpaaaaaaaiicaabaaaaaaaaaaadkaabaiaebaaaaaaaaaaaaaa
abeaaaaaaaaaiadpelaaaaafecaabaaaaaaaaaaadkaabaaaaaaaaaaabaaaaaah
bcaabaaaabaaaaaaegbcbaaaadaaaaaaegacbaaaaaaaaaaabaaaaaahccaabaaa
abaaaaaaegbcbaaaaeaaaaaaegacbaaaaaaaaaaabaaaaaahecaabaaaabaaaaaa
egbcbaaaafaaaaaaegacbaaaaaaaaaaabaaaaaahbcaabaaaaaaaaaaaegbcbaaa
acaaaaaaegacbaaaabaaaaaaaaaaaaahbcaabaaaaaaaaaaaakaabaaaaaaaaaaa
akaabaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegacbaaaabaaaaaaagaabaia
ebaaaaaaaaaaaaaaegbcbaaaacaaaaaaefaaaaajpcaabaaaaaaaaaaaegacbaaa
aaaaaaaaeghobaaaacaaaaaaaagabaaaacaaaaaadiaaaaaipcaabaaaaaaaaaaa
egaobaaaaaaaaaaaegiocaaaaaaaaaaaadaaaaaaefaaaaajpcaabaaaabaaaaaa
egbabaaaabaaaaaaeghobaaaabaaaaaaaagabaaaabaaaaaadiaaaaahpcaabaaa
aaaaaaaaegaobaaaaaaaaaaapgapbaaaabaaaaaadiaaaaaipcaabaaaabaaaaaa
egaobaaaabaaaaaaegiocaaaabaaaaaaaeaaaaaadcaaaaampccabaaaaaaaaaaa
egaobaaaabaaaaaaaceaaaaaaaaaaaeaaaaaaaeaaaaaaaeaaaaaiadpegaobaaa
aaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

SubProgram "flash " {
Keywords { }
Vector 0 [glstate_lightmodel_ambient]
Vector 1 [_ReflectColor]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
"agal_ps
c2 2.0 -1.0 1.0 0.0
[bc]
ciaaaaaaaaaaapacabaaaaoeaeaaaaaaaaaaaaaaafaababb tex r0, v1, s0 <2d wrap linear point>
aaaaaaaaaaaaabacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa mov r0.x, r0.w
adaaaaaaaaaaadacaaaaaafeacaaaaaaacaaaaaaabaaaaaa mul r0.xy, r0.xyyy, c2.x
abaaaaaaaaaaadacaaaaaafeacaaaaaaacaaaaffabaaaaaa add r0.xy, r0.xyyy, c2.y
adaaaaaaabaaabacaaaaaaffacaaaaaaaaaaaaffacaaaaaa mul r1.x, r0.y, r0.y
bfaaaaaaacaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa neg r2.x, r0.x
adaaaaaaacaaabacacaaaaaaacaaaaaaaaaaaaaaacaaaaaa mul r2.x, r2.x, r0.x
acaaaaaaabaaabacacaaaaaaacaaaaaaabaaaaaaacaaaaaa sub r1.x, r2.x, r1.x
abaaaaaaabaaabacabaaaaaaacaaaaaaacaaaakkabaaaaaa add r1.x, r1.x, c2.z
akaaaaaaabaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rsq r1.x, r1.x
afaaaaaaaaaaaeacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rcp r0.z, r1.x
bcaaaaaaabaaaeacafaaaaoeaeaaaaaaaaaaaakeacaaaaaa dp3 r1.z, v5, r0.xyzz
bcaaaaaaabaaabacaaaaaakeacaaaaaaadaaaaoeaeaaaaaa dp3 r1.x, r0.xyzz, v3
bcaaaaaaabaaacacaaaaaakeacaaaaaaaeaaaaoeaeaaaaaa dp3 r1.y, r0.xyzz, v4
bcaaaaaaaaaaabacabaaaakeacaaaaaaacaaaaoeaeaaaaaa dp3 r0.x, r1.xyzz, v2
adaaaaaaaaaaahacabaaaakeacaaaaaaaaaaaaaaacaaaaaa mul r0.xyz, r1.xyzz, r0.x
bfaaaaaaaaaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r0.xyz, r0.xyzz
adaaaaaaaaaaahacaaaaaakeacaaaaaaacaaaaaaabaaaaaa mul r0.xyz, r0.xyzz, c2.x
abaaaaaaaaaaahacaaaaaakeacaaaaaaacaaaaoeaeaaaaaa add r0.xyz, r0.xyzz, v2
ciaaaaaaabaaapacaaaaaageacaaaaaaacaaaaaaafbababb tex r1, r0.xyzy, s2 <cube wrap linear point>
ciaaaaaaaaaaapacaaaaaaoeaeaaaaaaabaaaaaaafaababb tex r0, v0, s1 <2d wrap linear point>
adaaaaaaabaaapacabaaaaoeacaaaaaaabaaaaoeabaaaaaa mul r1, r1, c1
adaaaaaaacaaapacaaaaaaoeacaaaaaaaaaaaaoeabaaaaaa mul r2, r0, c0
adaaaaaaaaaaapacaaaaaappacaaaaaaabaaaaoeacaaaaaa mul r0, r0.w, r1
adaaaaaaabaaahacacaaaakeacaaaaaaacaaaaaaabaaaaaa mul r1.xyz, r2.xyzz, c2.x
aaaaaaaaabaaaiacacaaaappacaaaaaaaaaaaaaaaaaaaaaa mov r1.w, r2.w
abaaaaaaaaaaapacabaaaaoeacaaaaaaaaaaaaoeacaaaaaa add r0, r1, r0
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { }
ConstBuffer "$Globals" 80 // 64 used size, 5 vars
Vector 48 [_ReflectColor] 4
ConstBuffer "UnityPerFrame" 208 // 80 used size, 4 vars
Vector 64 [glstate_lightmodel_ambient] 4
BindCB "$Globals" 0
BindCB "UnityPerFrame" 1
SetTexture 0 [_BumpMap] 2D 0
SetTexture 1 [_MainTex] 2D 1
SetTexture 2 [_Cube] CUBE 2
// 19 instructions, 2 temp regs, 0 temp arrays:
// ALU 15 float, 0 int, 0 uint
// TEX 3 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_1
eefiecedkkgmdinhcceppabadcmagppncjijlfhiabaaaaaakiagaaaaaeaaaaaa
daaaaaaagmacaaaakeafaaaaheagaaaaebgpgodjdeacaaaadeacaaaaaaacpppp
omabaaaaeiaaaaaaacaadaaaaaaaeiaaaaaaeiaaadaaceaaaaaaeiaaaaaaaaaa
abababaaacacacaaaaaaadaaabaaaaaaaaaaaaaaabaaaeaaabaaabaaaaaaaaaa
aaacppppfbaaaaafacaaapkaaaaaaaeaaaaaialpaaaaaaaaaaaaiadpfbaaaaaf
adaaapkaaaaaaaeaaaaaaaeaaaaaaaeaaaaaiadpbpaaaaacaaaaaaiaaaaaapla
bpaaaaacaaaaaaiaabaaahlabpaaaaacaaaaaaiaacaaahlabpaaaaacaaaaaaia
adaaahlabpaaaaacaaaaaaiaaeaaahlabpaaaaacaaaaaajaaaaiapkabpaaaaac
aaaaaajaabaiapkabpaaaaacaaaaaajiacaiapkaabaaaaacaaaaadiaaaaablla
ecaaaaadaaaacpiaaaaaoeiaaaaioekaaeaaaaaeabaacbiaaaaappiaacaaaaka
acaaffkaaeaaaaaeabaacciaaaaaffiaacaaaakaacaaffkafkaaaaaeabaadiia
abaaoeiaabaaoeiaacaakkkaacaaaaadabaaciiaabaappibacaappkaahaaaaac
abaaciiaabaappiaagaaaaacabaaceiaabaappiaaiaaaaadaaaacbiaacaaoela
abaaoeiaaiaaaaadaaaacciaadaaoelaabaaoeiaaiaaaaadaaaaceiaaeaaoela
abaaoeiaaiaaaaadaaaaaiiaabaaoelaaaaaoeiaacaaaaadaaaaaiiaaaaappia
aaaappiaaeaaaaaeaaaachiaaaaaoeiaaaaappibabaaoelaecaaaaadaaaaapia
aaaaoeiaacaioekaecaaaaadabaacpiaaaaaoelaabaioekaafaaaaadaaaaapia
aaaaoeiaaaaaoekaafaaaaadaaaacpiaabaappiaaaaaoeiaafaaaaadabaacpia
abaaoeiaabaaoekaaeaaaaaeaaaacpiaabaaoeiaadaaoekaaaaaoeiaabaaaaac
aaaicpiaaaaaoeiappppaaaafdeieefcdaadaaaaeaaaaaaammaaaaaafjaaaaae
egiocaaaaaaaaaaaaeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafkaaaaad
aagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaafkaaaaadaagabaaaacaaaaaa
fibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaa
fidaaaaeaahabaaaacaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaagcbaaaad
mcbabaaaabaaaaaagcbaaaadhcbabaaaacaaaaaagcbaaaadhcbabaaaadaaaaaa
gcbaaaadhcbabaaaaeaaaaaagcbaaaadhcbabaaaafaaaaaagfaaaaadpccabaaa
aaaaaaaagiaaaaacacaaaaaaefaaaaajpcaabaaaaaaaaaaaogbkbaaaabaaaaaa
eghobaaaaaaaaaaaaagabaaaaaaaaaaadcaaaaapdcaabaaaaaaaaaaahgapbaaa
aaaaaaaaaceaaaaaaaaaaaeaaaaaaaeaaaaaaaaaaaaaaaaaaceaaaaaaaaaialp
aaaaialpaaaaaaaaaaaaaaaaapaaaaahicaabaaaaaaaaaaaegaabaaaaaaaaaaa
egaabaaaaaaaaaaaddaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaaabeaaaaa
aaaaiadpaaaaaaaiicaabaaaaaaaaaaadkaabaiaebaaaaaaaaaaaaaaabeaaaaa
aaaaiadpelaaaaafecaabaaaaaaaaaaadkaabaaaaaaaaaaabaaaaaahbcaabaaa
abaaaaaaegbcbaaaadaaaaaaegacbaaaaaaaaaaabaaaaaahccaabaaaabaaaaaa
egbcbaaaaeaaaaaaegacbaaaaaaaaaaabaaaaaahecaabaaaabaaaaaaegbcbaaa
afaaaaaaegacbaaaaaaaaaaabaaaaaahbcaabaaaaaaaaaaaegbcbaaaacaaaaaa
egacbaaaabaaaaaaaaaaaaahbcaabaaaaaaaaaaaakaabaaaaaaaaaaaakaabaaa
aaaaaaaadcaaaaakhcaabaaaaaaaaaaaegacbaaaabaaaaaaagaabaiaebaaaaaa
aaaaaaaaegbcbaaaacaaaaaaefaaaaajpcaabaaaaaaaaaaaegacbaaaaaaaaaaa
eghobaaaacaaaaaaaagabaaaacaaaaaadiaaaaaipcaabaaaaaaaaaaaegaobaaa
aaaaaaaaegiocaaaaaaaaaaaadaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaa
abaaaaaaeghobaaaabaaaaaaaagabaaaabaaaaaadiaaaaahpcaabaaaaaaaaaaa
egaobaaaaaaaaaaapgapbaaaabaaaaaadiaaaaaipcaabaaaabaaaaaaegaobaaa
abaaaaaaegiocaaaabaaaaaaaeaaaaaadcaaaaampccabaaaaaaaaaaaegaobaaa
abaaaaaaaceaaaaaaaaaaaeaaaaaaaeaaaaaaaeaaaaaiadpegaobaaaaaaaaaaa
doaaaaabejfdeheomiaaaaaaahaaaaaaaiaaaaaalaaaaaaaaaaaaaaaabaaaaaa
adaaaaaaaaaaaaaaapaaaaaalmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaa
adadaaaalmaaaaaaabaaaaaaaaaaaaaaadaaaaaaabaaaaaaamamaaaalmaaaaaa
acaaaaaaaaaaaaaaadaaaaaaacaaaaaaahahaaaalmaaaaaaadaaaaaaaaaaaaaa
adaaaaaaadaaaaaaahahaaaalmaaaaaaaeaaaaaaaaaaaaaaadaaaaaaaeaaaaaa
ahahaaaalmaaaaaaafaaaaaaaaaaaaaaadaaaaaaafaaaaaaahahaaaafdfgfpfa
epfdejfeejepeoaafeeffiedepepfceeaaklklklepfdeheocmaaaaaaabaaaaaa
aiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfe
gbhcghgfheaaklkl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3"
}

}

#LINE 84
  
		} 
	}
	
	// ------------------------------------------------------------------
	//  No vertex or fragment programs
	
	SubShader {
		Pass { 
			Tags {"LightMode" = "Always"}
			Name "BASE"
			BindChannels {
				Bind "Vertex", vertex
				Bind "Normal", normal
			}
			SetTexture [_Cube] {
				constantColor [_ReflectColor]
				combine texture * constant
			}
		}
	}
}
	
FallBack "VertexLit", 1

}
