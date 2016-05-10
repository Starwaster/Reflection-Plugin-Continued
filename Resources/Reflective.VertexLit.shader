Shader "Reflective/VertexLit" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Spec Color", Color) = (1,1,1,1)
	_Shininess ("Shininess", Range (0.03, 1)) = 0.7
	_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	_MainTex ("Base (RGB) RefStrength (A)", 2D) = "white" {} 
	_Cube ("Reflection Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
}

Category {
	Tags { "RenderType"="Opaque" }
	LOD 150
	
	SubShader {
	
		// First pass does reflection cubemap
		Pass { 
			Name "BASE"
			Tags {"LightMode" = "Always"}
Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 16 to 16
//   d3d9 - ALU: 16 to 16
//   d3d11 - ALU: 17 to 17, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 17 to 17, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord" TexCoord0
Vector 9 [_WorldSpaceCameraPos]
Matrix 5 [_Object2World]
Vector 10 [unity_Scale]
Vector 11 [_MainTex_ST]
"!!ARBvp1.0
# 16 ALU
PARAM c[12] = { { 2 },
		state.matrix.mvp,
		program.local[5..11] };
TEMP R0;
TEMP R1;
TEMP R2;
MUL R2.xyz, vertex.normal, c[10].w;
DP3 R0.z, R2, c[7];
DP3 R0.y, R2, c[6];
DP3 R0.x, R2, c[5];
DP4 R1.z, vertex.position, c[7];
DP4 R1.x, vertex.position, c[5];
DP4 R1.y, vertex.position, c[6];
ADD R1.xyz, -R1, c[9];
DP3 R0.w, R0, -R1;
MUL R0.xyz, R0, R0.w;
MAD result.texcoord[1].xyz, -R0, c[0].x, -R1;
MAD result.texcoord[0].xy, vertex.texcoord[0], c[11], c[11].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 16 instructions, 3 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [_MainTex_ST]
"vs_2_0
; 16 ALU
def c11, 2.00000000, 0, 0, 0
dcl_position0 v0
dcl_normal0 v1
dcl_texcoord0 v2
mul r2.xyz, v1, c9.w
dp3 r0.z, r2, c6
dp3 r0.y, r2, c5
dp3 r0.x, r2, c4
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
add r1.xyz, -r1, c8
dp3 r0.w, r0, -r1
mul r0.xyz, r0, r0.w
mad oT1.xyz, -r0, c11.x, -r1
mad oT0.xy, v2, c10, c10.zwzw
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 48 // 32 used size, 3 vars
Vector 16 [_MainTex_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 18 instructions, 3 temp regs, 0 temp arrays:
// ALU 17 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedicmmgiogcgcpgihjnhlmfkajpnbonjpcabaaaaaaeaaeaaaaadaaaaaa
cmaaaaaamaaaaaaadaabaaaaejfdeheoimaaaaaaaeaaaaaaaiaaaaaagiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaahbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapaaaaaahjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaaiaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaafaepfdej
feejepeoaafeebeoehefeofeaaeoepfcenebemaafeeffiedepepfceeaaklklkl
epfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaa
fmaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaahaiaaaafdfgfpfaepfdejfe
ejepeoaafeeffiedepepfceeaaklklklfdeieefcaiadaaaaeaaaabaamcaaaaaa
fjaaaaaeegiocaaaaaaaaaaaacaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaa
fjaaaaaeegiocaaaacaaaaaabfaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaad
hcbabaaaacaaaaaafpaaaaaddcbabaaaadaaaaaaghaaaaaepccabaaaaaaaaaaa
abaaaaaagfaaaaaddccabaaaabaaaaaagfaaaaadhccabaaaacaaaaaagiaaaaac
adaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaa
abaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaaaaaaaaaagbabaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaa
acaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaa
egiocaaaacaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaal
dccabaaaabaaaaaaegbabaaaadaaaaaaegiacaaaaaaaaaaaabaaaaaaogikcaaa
aaaaaaaaabaaaaaadiaaaaaihcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiccaaa
acaaaaaaanaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaamaaaaaa
agbabaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaa
acaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaa
aaaaaaaaegiccaaaacaaaaaaapaaaaaapgbpbaaaaaaaaaaaegacbaaaaaaaaaaa
aaaaaaajhcaabaaaaaaaaaaaegacbaiaebaaaaaaaaaaaaaaegiccaaaabaaaaaa
aeaaaaaadiaaaaaihcaabaaaabaaaaaaegbcbaaaacaaaaaapgipcaaaacaaaaaa
beaaaaaadiaaaaaihcaabaaaacaaaaaafgafbaaaabaaaaaaegiccaaaacaaaaaa
anaaaaaadcaaaaaklcaabaaaabaaaaaaegiicaaaacaaaaaaamaaaaaaagaabaaa
abaaaaaaegaibaaaacaaaaaadcaaaaakhcaabaaaabaaaaaaegiccaaaacaaaaaa
aoaaaaaakgakbaaaabaaaaaaegadbaaaabaaaaaabaaaaaaiicaabaaaaaaaaaaa
egacbaiaebaaaaaaaaaaaaaaegacbaaaabaaaaaaaaaaaaahicaabaaaaaaaaaaa
dkaabaaaaaaaaaaadkaabaaaaaaaaaaadcaaaaalhccabaaaacaaaaaaegacbaaa
abaaaaaapgapbaiaebaaaaaaaaaaaaaaegacbaiaebaaaaaaaaaaaaaadoaaaaab
"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [_MainTex_ST]
"agal_vs
c11 2.0 0.0 0.0 0.0
[bc]
adaaaaaaacaaahacabaaaaoeaaaaaaaaajaaaappabaaaaaa mul r2.xyz, a1, c9.w
bcaaaaaaaaaaaeacacaaaakeacaaaaaaagaaaaoeabaaaaaa dp3 r0.z, r2.xyzz, c6
bcaaaaaaaaaaacacacaaaakeacaaaaaaafaaaaoeabaaaaaa dp3 r0.y, r2.xyzz, c5
bcaaaaaaaaaaabacacaaaakeacaaaaaaaeaaaaoeabaaaaaa dp3 r0.x, r2.xyzz, c4
bdaaaaaaabaaaeacaaaaaaoeaaaaaaaaagaaaaoeabaaaaaa dp4 r1.z, a0, c6
bdaaaaaaabaaabacaaaaaaoeaaaaaaaaaeaaaaoeabaaaaaa dp4 r1.x, a0, c4
bdaaaaaaabaaacacaaaaaaoeaaaaaaaaafaaaaoeabaaaaaa dp4 r1.y, a0, c5
bfaaaaaaabaaahacabaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r1.xyz, r1.xyzz
abaaaaaaabaaahacabaaaakeacaaaaaaaiaaaaoeabaaaaaa add r1.xyz, r1.xyzz, c8
bfaaaaaaacaaahacabaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r2.xyz, r1.xyzz
bcaaaaaaaaaaaiacaaaaaakeacaaaaaaacaaaakeacaaaaaa dp3 r0.w, r0.xyzz, r2.xyzz
adaaaaaaaaaaahacaaaaaakeacaaaaaaaaaaaappacaaaaaa mul r0.xyz, r0.xyzz, r0.w
bfaaaaaaaaaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r0.xyz, r0.xyzz
adaaaaaaaaaaahacaaaaaakeacaaaaaaalaaaaaaabaaaaaa mul r0.xyz, r0.xyzz, c11.x
acaaaaaaabaaahaeaaaaaakeacaaaaaaabaaaakeacaaaaaa sub v1.xyz, r0.xyzz, r1.xyzz
adaaaaaaaaaaadacadaaaaoeaaaaaaaaakaaaaoeabaaaaaa mul r0.xy, a3, c10
abaaaaaaaaaaadaeaaaaaafeacaaaaaaakaaaaooabaaaaaa add v0.xy, r0.xyyy, c10.zwzw
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaaaaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c0
aaaaaaaaabaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v1.w, c0
"
}

SubProgram "d3d11_9x " {
Keywords { }
Bind "vertex" Vertex
Bind "normal" Normal
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 48 // 32 used size, 3 vars
Vector 16 [_MainTex_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 18 instructions, 3 temp regs, 0 temp arrays:
// ALU 17 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_1
eefiecedlocjmjeecfnalplnbbaidbghhfocogagabaaaaaadeagaaaaaeaaaaaa
daaaaaaacaacaaaadaafaaaameafaaaaebgpgodjoiabaaaaoiabaaaaaaacpopp
ieabaaaageaaaaaaafaaceaaaaaagaaaaaaagaaaaaaaceaaabaagaaaaaaaabaa
abaaabaaaaaaaaaaabaaaeaaabaaacaaaaaaaaaaacaaaaaaaeaaadaaaaaaaaaa
acaaamaaaeaaahaaaaaaaaaaacaabeaaabaaalaaaaaaaaaaaaaaaaaaaaacpopp
bpaaaaacafaaaaiaaaaaapjabpaaaaacafaaaciaacaaapjabpaaaaacafaaadia
adaaapjaaeaaaaaeaaaaadoaadaaoejaabaaoekaabaaookaafaaaaadaaaaahia
aaaaffjaaiaaoekaaeaaaaaeaaaaahiaahaaoekaaaaaaajaaaaaoeiaaeaaaaae
aaaaahiaajaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaahiaakaaoekaaaaappja
aaaaoeiaacaaaaadaaaaahiaaaaaoeibacaaoekaafaaaaadabaaahiaacaaoeja
alaappkaafaaaaadacaaahiaabaaffiaaiaaoekaaeaaaaaeabaaaliaahaakeka
abaaaaiaacaakeiaaeaaaaaeabaaahiaajaaoekaabaakkiaabaapeiaaiaaaaad
aaaaaiiaaaaaoeibabaaoeiaacaaaaadaaaaaiiaaaaappiaaaaappiaaeaaaaae
abaaahoaabaaoeiaaaaappibaaaaoeibafaaaaadaaaaapiaaaaaffjaaeaaoeka
aeaaaaaeaaaaapiaadaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaafaaoeka
aaaakkjaaaaaoeiaaeaaaaaeaaaaapiaagaaoekaaaaappjaaaaaoeiaaeaaaaae
aaaaadmaaaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiappppaaaa
fdeieefcaiadaaaaeaaaabaamcaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaa
fjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaaeegiocaaaacaaaaaabfaaaaaa
fpaaaaadpcbabaaaaaaaaaaafpaaaaadhcbabaaaacaaaaaafpaaaaaddcbabaaa
adaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaaabaaaaaa
gfaaaaadhccabaaaacaaaaaagiaaaaacadaaaaaadiaaaaaipcaabaaaaaaaaaaa
fgbfbaaaaaaaaaaaegiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaacaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaapgbpbaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaaldccabaaaabaaaaaaegbabaaaadaaaaaa
egiacaaaaaaaaaaaabaaaaaaogikcaaaaaaaaaaaabaaaaaadiaaaaaihcaabaaa
aaaaaaaafgbfbaaaaaaaaaaaegiccaaaacaaaaaaanaaaaaadcaaaaakhcaabaaa
aaaaaaaaegiccaaaacaaaaaaamaaaaaaagbabaaaaaaaaaaaegacbaaaaaaaaaaa
dcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaaoaaaaaakgbkbaaaaaaaaaaa
egacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaapaaaaaa
pgbpbaaaaaaaaaaaegacbaaaaaaaaaaaaaaaaaajhcaabaaaaaaaaaaaegacbaia
ebaaaaaaaaaaaaaaegiccaaaabaaaaaaaeaaaaaadiaaaaaihcaabaaaabaaaaaa
egbcbaaaacaaaaaapgipcaaaacaaaaaabeaaaaaadiaaaaaihcaabaaaacaaaaaa
fgafbaaaabaaaaaaegiccaaaacaaaaaaanaaaaaadcaaaaaklcaabaaaabaaaaaa
egiicaaaacaaaaaaamaaaaaaagaabaaaabaaaaaaegaibaaaacaaaaaadcaaaaak
hcaabaaaabaaaaaaegiccaaaacaaaaaaaoaaaaaakgakbaaaabaaaaaaegadbaaa
abaaaaaabaaaaaaiicaabaaaaaaaaaaaegacbaiaebaaaaaaaaaaaaaaegacbaaa
abaaaaaaaaaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaadkaabaaaaaaaaaaa
dcaaaaalhccabaaaacaaaaaaegacbaaaabaaaaaapgapbaiaebaaaaaaaaaaaaaa
egacbaiaebaaaaaaaaaaaaaadoaaaaabejfdeheoimaaaaaaaeaaaaaaaiaaaaaa
giaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaahbaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaabaaaaaaapaaaaaahjaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
acaaaaaaahahaaaaiaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaa
faepfdejfeejepeoaafeebeoehefeofeaaeoepfcenebemaafeeffiedepepfcee
aaklklklepfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaa
adaaaaaaaaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaa
adamaaaafmaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaahaiaaaafdfgfpfa
epfdejfeejepeoaafeeffiedepepfceeaaklklkl"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 4 to 4, TEX: 2 to 2
//   d3d9 - ALU: 3 to 3, TEX: 2 to 2
//   d3d11 - ALU: 2 to 2, TEX: 2 to 2, FLOW: 1 to 1
//   d3d11_9x - ALU: 2 to 2, TEX: 2 to 2, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 0 [_ReflectColor]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_Cube] CUBE
"!!ARBfp1.0
# 4 ALU, 2 TEX
PARAM c[1] = { program.local[0] };
TEMP R0;
TEMP R1;
TEX R1.w, fragment.texcoord[0], texture[0], 2D;
TEX R0, fragment.texcoord[1], texture[1], CUBE;
MUL R0, R0, R1.w;
MUL result.color, R0, c[0];
END
# 4 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_ReflectColor]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_Cube] CUBE
"ps_2_0
; 3 ALU, 2 TEX
dcl_2d s0
dcl_cube s1
dcl t0.xy
dcl t1.xyz
texld r1, t0, s0
texld r0, t1, s1
mul_pp r0, r0, r1.w
mul_pp r0, r0, c0
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 48 // 48 used size, 3 vars
Vector 32 [_ReflectColor] 4
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
SetTexture 1 [_Cube] CUBE 1
// 5 instructions, 2 temp regs, 0 temp arrays:
// ALU 2 float, 0 int, 0 uint
// TEX 2 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedkigajmogkaafgooagellghdhiomiclefabaaaaaanmabaaaaadaaaaaa
cmaaaaaajmaaaaaanaaaaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafmaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklklepfdeheo
cmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaa
apaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcaeabaaaaeaaaaaaaebaaaaaa
fjaaaaaeegiocaaaaaaaaaaaadaaaaaafkaaaaadaagabaaaaaaaaaaafkaaaaad
aagabaaaabaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaafidaaaaeaahabaaa
abaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaagcbaaaadhcbabaaaacaaaaaa
gfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaefaaaaajpcaabaaaaaaaaaaa
egbabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaaefaaaaajpcaabaaa
abaaaaaaegbcbaaaacaaaaaaeghobaaaabaaaaaaaagabaaaabaaaaaadiaaaaah
pcaabaaaaaaaaaaapgapbaaaaaaaaaaaegaobaaaabaaaaaadiaaaaaipccabaaa
aaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaacaaaaaadoaaaaab"
}

SubProgram "flash " {
Keywords { }
Vector 0 [_ReflectColor]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_Cube] CUBE
"agal_ps
[bc]
ciaaaaaaabaaapacaaaaaaoeaeaaaaaaaaaaaaaaafaababb tex r1, v0, s0 <2d wrap linear point>
ciaaaaaaaaaaapacabaaaaoeaeaaaaaaabaaaaaaafbababb tex r0, v1, s1 <cube wrap linear point>
adaaaaaaaaaaapacaaaaaaoeacaaaaaaabaaaappacaaaaaa mul r0, r0, r1.w
adaaaaaaaaaaapacaaaaaaoeacaaaaaaaaaaaaoeabaaaaaa mul r0, r0, c0
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { }
ConstBuffer "$Globals" 48 // 48 used size, 3 vars
Vector 32 [_ReflectColor] 4
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
SetTexture 1 [_Cube] CUBE 1
// 5 instructions, 2 temp regs, 0 temp arrays:
// ALU 2 float, 0 int, 0 uint
// TEX 2 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_1
eefiecedpldbegjkkaibpiicpkknblcnfkdnmicoabaaaaaakeacaaaaaeaaaaaa
daaaaaaapeaaaaaaaaacaaaahaacaaaaebgpgodjlmaaaaaalmaaaaaaaaacpppp
ieaaaaaadiaaaaaaabaacmaaaaaadiaaaaaadiaaacaaceaaaaaadiaaaaaaaaaa
abababaaaaaaacaaabaaaaaaaaaaaaaaaaacppppbpaaaaacaaaaaaiaaaaaadla
bpaaaaacaaaaaaiaabaaahlabpaaaaacaaaaaajaaaaiapkabpaaaaacaaaaaaji
abaiapkaecaaaaadaaaacpiaaaaaoelaaaaioekaecaaaaadabaacpiaabaaoela
abaioekaafaaaaadaaaacpiaaaaappiaabaaoeiaafaaaaadaaaacpiaaaaaoeia
aaaaoekaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefcaeabaaaaeaaaaaaa
ebaaaaaafjaaaaaeegiocaaaaaaaaaaaadaaaaaafkaaaaadaagabaaaaaaaaaaa
fkaaaaadaagabaaaabaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaafidaaaae
aahabaaaabaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaagcbaaaadhcbabaaa
acaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaefaaaaajpcaabaaa
aaaaaaaaegbabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaaefaaaaaj
pcaabaaaabaaaaaaegbcbaaaacaaaaaaeghobaaaabaaaaaaaagabaaaabaaaaaa
diaaaaahpcaabaaaaaaaaaaapgapbaaaaaaaaaaaegaobaaaabaaaaaadiaaaaai
pccabaaaaaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaacaaaaaadoaaaaab
ejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadadaaaa
fmaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaahahaaaafdfgfpfaepfdejfe
ejepeoaafeeffiedepepfceeaaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaa
caaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgf
heaaklkl"
}

}

#LINE 60

		}
		
		// Vertex Lit
		Pass {
			Tags { "LightMode" = "Vertex" }
			Blend One One ZWrite Off Fog { Color (0,0,0,0) }
			Lighting On
			Material {
				Diffuse [_Color]
				Emission [_PPLAmbient]
				Specular [_SpecColor]
				Shininess [_Shininess]
			}
			SeparateSpecular On
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 7 to 7, TEX: 1 to 1
//   d3d9 - ALU: 7 to 7, TEX: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 0 [_SpecColor]
SetTexture 0 [_MainTex] 2D
"!!ARBfp1.0
# 7 ALU, 1 TEX
PARAM c[2] = { program.local[0],
		{ 0.2199707, 0.70703125, 0.070983887, 2 } };
TEMP R0;
TEMP R1;
TEX R0, fragment.texcoord[0], texture[0], 2D;
MUL R1.xyz, R0.w, fragment.color.secondary;
MAD R0.xyz, R0, fragment.color.primary, R1;
DP3 R1.w, fragment.color.secondary, c[1];
MAD R1.x, R1.w, c[0].w, fragment.color.primary.w;
MUL result.color.xyz, R0, c[1].w;
MUL result.color.w, R0, R1.x;
END
# 7 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_SpecColor]
SetTexture 0 [_MainTex] 2D
"ps_2_0
; 7 ALU, 1 TEX
dcl_2d s0
def c1, 0.21997070, 0.70703125, 0.07098389, 2.00000000
dcl t0.xy
dcl v0
dcl v1.xyz
texld r1, t0, s0
mul_pp r2.xyz, r1.w, v1
dp3_pp r0.x, v1, c1
mad_pp r1.xyz, r1, v0, r2
mad_pp r0.x, r0, c0.w, v0.w
mul_pp r1.xyz, r1, c1.w
mul_pp r1.w, r1, r0.x
mov_pp oC0, r1
"
}

}

#LINE 99

			SetTexture[_MainTex] {}
		}
		
		// Lightmapped
		Pass {
			Tags { "LightMode" = "VertexLM" }
			Blend One One ZWrite Off Fog { Color (0,0,0,0) }
			ColorMask RGB
			
			BindChannels {
				Bind "Vertex", vertex
				Bind "normal", normal
				Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
				Bind "texcoord", texcoord1 // main uses 1st uv
			}
			
			SetTexture [unity_Lightmap] {
				matrix [unity_LightmapMatrix]
				constantColor [_Color]
				combine texture * constant
			}
			SetTexture [_MainTex] {
				combine texture * previous DOUBLE, texture * primary
			}
		}
		
		// Lightmapped, encoded as RGBM
		Pass {
			Tags { "LightMode" = "VertexLMRGBM" }
			Blend One One ZWrite Off Fog { Color (0,0,0,0) }
			ColorMask RGB
			
			BindChannels {
				Bind "Vertex", vertex
				Bind "normal", normal
				Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
				Bind "texcoord1", texcoord1 // unused
				Bind "texcoord", texcoord2 // main uses 1st uv
			}
			
			SetTexture [unity_Lightmap] {
				matrix [unity_LightmapMatrix]
				combine texture * texture alpha DOUBLE
			}
			SetTexture [unity_Lightmap] {
				constantColor [_Color]
				combine previous * constant
			}
			SetTexture [_MainTex] {
				combine texture * previous QUAD, texture * primary
			}
		}
	}

	
	SubShader {
		Pass { 
			Name "BASE"
			Tags { "LightMode" = "Vertex" }
			Material {
				Diffuse [_Color]
				Ambient (1,1,1,1)
				Shininess [_Shininess]
				Specular [_SpecColor]
			}
			Lighting On
			SeparateSpecular on
			SetTexture [_MainTex] {
				combine texture * primary DOUBLE, texture * primary
			}
			SetTexture [_Cube] {
				combine texture * previous alpha + previous, previous
			}
		}
	}
}

// Fallback for cards that don't do cubemapping
FallBack "VertexLit"
}
