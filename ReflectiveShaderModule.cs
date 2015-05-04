using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using System.IO;
using System.Text;
using System.Reflection;

namespace ReflectionPlugin
{
    public class ReflectiveShaderModule : PartModule
    {
        [KSPField(isPersistant = false)]
        public int CubeMapSize = 128;
        [KSPField(isPersistant = false)]
        public float FarClipPlane = 1000000000f;
        [KSPField(isPersistant = false)]
        public float NearClipPlane = -1f;
        [KSPField(isPersistant = false)]
        public string MeshesToChange = "";
        [KSPField(isPersistant = false)]
        public bool OneFacePerFrame = true;
        [KSPField(isPersistant = false)]
        public float ParallaxHeight = 0.02f;
        [KSPField(isPersistant = false)]
        public float ReflectionStrength = 1.0f;
        [KSPField(isPersistant = false)]
        public Color ReflectionColor = new Color(0.5f, 0.5f, 0.5f, 0.5f);
        [KSPField(isPersistant = false)]
        public Color _Color = new Color(1.0f, 1.0f, 1.0f, 1.0f);
        [KSPField(isPersistant = false)]
        public string ShaderName = "";
        [KSPField(isPersistant = false)]
        public float Shininess = -1f;
        [KSPField(isPersistant = false)]
        public float SpecColorA = 0.5f;
        [KSPField(isPersistant = false)]
        public float SpecColorB = 0.5f;
        [KSPField(isPersistant = false)]
        public float SpecColorG = 0.5f;
        [KSPField(isPersistant = false)]
        public float SpecColorR = -1f;
        [KSPField(isPersistant = false)]
        public float rimFalloff = 0;
        [KSPField(isPersistant = false)]
        public Color rimColor = new Color(0f, 0f, 0f, 0f);
        [KSPField(isPersistant = false)]
        public bool realTimeReflection = true;
        [KSPField(isPersistant = false)]
        public double updateRate = 60.0;
        [KSPField(isPersistant = false, guiActive = false, guiName = "Last Scene", guiUnits = "", guiFormat = "G")]
        public string lastScene = "";
        [KSPField(isPersistant = false, guiActive = false, guiName = "Shader", guiUnits = "", guiFormat = "G")]
        public string scriptStatus = "";



        private Shader _rShader;
        private ReflectiveScript reflectiveScript = null;

        public override void OnStart(PartModule.StartState state)
        {
            Debug.Log((object)"RP: Starting ReflectionPlugin .. ");
			GameEvents.onVesselGoOffRails.Add(RefreshReflection);
            if (this.ShaderName == string.Empty)
            {
                Debug.Log((object)"RP: Defaulting shader to \"Reflective/VertexLit\"");
                this.ShaderName = "Reflective/VertexLit";
            }
            this._rShader = Shader.Find(this.ShaderName);
            Shader fallbackShader = Shader.Find("Reflective/VertexLit");

            if ((UnityEngine.Object)this._rShader == (UnityEngine.Object)null)
            {
                Debug.LogWarning((object)string.Format("RP: Could not find the specified shader \"{0}\".", (object)this.ShaderName));
                Debug.LogWarning((object)"RP: Simple reflective shaders:");
                Debug.LogWarning((object)"RP: -\"Reflective/Diffuse\"");
                Debug.LogWarning((object)"RP: -\"Reflective/Specular\"");
                Debug.LogWarning((object)"RP: -\"Reflective/VertexLit\"");
                Debug.LogWarning((object)"RP: Advanced reflective shaders:");
                Debug.LogWarning((object)"RP: -\"Reflective/Bumped Diffuse\"");
                Debug.LogWarning((object)"RP: -\"Reflective/Bumped Specular\"");
                Debug.LogWarning((object)"RP: -\"Reflective/Bumped Unlit\"");
                Debug.LogWarning((object)"RP: -\"Reflective/Bumped VertexLit\"");
                Debug.LogWarning((object)"RP: -\"Reflective/Parallax Diffuse\"");
                Debug.LogWarning((object)"RP: -\"Reflective/Parallax Specular\"");
                // Try to handle fallback later during material building
                // This is so we can try to load and deserialize missing shaders from compiled shader code.
                this._rShader = null;
                //this._rShader = Shader.Find(this.ShaderName);
                //if ((UnityEngine.Object)this._rShader == (UnityEngine.Object)null)
                //{
                //    Debug.LogWarning((object)"RP: Fallback shader VertexLit failed.");
                //}
            }
            else
            {
                Debug.LogWarning((object)string.Format("RP: Found shader \"{0}\".", (object)this._rShader.name));
            }

            if (this.MeshesToChange == string.Empty)
            {
                Debug.Log((object)"RP: Applying changes to part ..");
                this.ReplaceShader(this.part.FindModelComponent<UnityEngine.Renderer>());
            }
            else
            {
                Debug.Log((object)"RP: Applying changes to meshes ..");
                List<string> meshNamesList = Enumerable.ToList<string>((IEnumerable<string>)this.MeshesToChange.Split(new char[1] { ',' }));
                MeshFilter[] modelComponents = this.part.FindModelComponents<MeshFilter>();
                if (this.MeshesToChange == "all")
                {
                    foreach (MeshFilter meshFilter in modelComponents)
                    {
                        Debug.Log((object)("RP: Applying changes to mesh: " + meshFilter.name));
                        this.ReplaceShader(meshFilter.GetComponent<UnityEngine.Renderer>());
                    }
                }
                else
                {
                    foreach (MeshFilter meshFilter in Enumerable.Where<MeshFilter>((IEnumerable<MeshFilter>)modelComponents, (Func<MeshFilter, bool>)(mesh => meshNamesList.Contains(mesh.name))))
                    {
                        Debug.Log((object)("RP: Applying changes to mesh: " + meshFilter.name));
                        this.ReplaceShader(meshFilter.GetComponent<UnityEngine.Renderer>());
                    }
                }
            }
            Debug.Log((object)"RP: Done.");
        }


        private void ReplaceShader(UnityEngine.Renderer pRenderer)
        {
            if ((object)pRenderer != null)
            {
                Debug.Log((object)string.Format("RP: Renderer found: {0}", (object)this._rShader));
                Material material;
				string shaderName = this.ShaderName;
				string resourceNamesString = "EMBEDDED RESOURCE NAMES\n";

				shaderName = shaderName.Replace (" ", "_");
				shaderName = shaderName.Replace ("/", ".");

                if (this._rShader == null)
                {
                    Debug.Log((object)("RP: null shader. Trying to retrieve ReflectionPlugin.Shaders." + shaderName));
                    Assembly assembly = Assembly.GetExecutingAssembly();

					string[] resourceNamesList = assembly.GetManifestResourceNames();
					foreach (string resourceName in resourceNamesList)
					{
						resourceNamesString += resourceName + "\n";
					}

					Debug.Log (resourceNamesString);

					try
					{
						Debug.Log ("[ReflectionPlugin] Looking for resource " + shaderName);
                    	
						StreamReader shaderStreamReader = new StreamReader(assembly.GetManifestResourceStream(/*"ReflectionPlugin.Shaders." + */"ReflectionPlugin.Resources." + shaderName + ".shader"));

						Debug.Log ("[ReflectionPlugin] Got " + shaderName);

						material = new Material(shaderStreamReader.ReadToEnd())
						{
							mainTexture = pRenderer.material.mainTexture
						};
					}
					catch (Exception e)
					{
						Debug.Log ("ReflectionPlugin caught exception " + e.ToString() + " (" + e.Message + ")");

						shaderName = "Reflective.VertexLit";
						Debug.Log ("[ReflectionPlugin] Looking for fallback resource " + shaderName);
						
						StreamReader shaderStreamReader = new StreamReader(assembly.GetManifestResourceStream("ReflectionPlugin.Resources." + shaderName + ".shader"));
						
						Debug.Log ("[ReflectionPlugin] Got " + shaderName);
						
						material = new Material(shaderStreamReader.ReadToEnd())
						{
							mainTexture = pRenderer.material.mainTexture
						};
					}
					Debug.Log ("[ReflectionPlugin] Initialized Material: " + material.ToString ());
                }
                else
                {
                    material = new Material(this._rShader)
                    {
                        mainTexture = pRenderer.material.mainTexture
                    };
                }
                Texture texture1 = pRenderer.material.GetTexture("_BumpMap");
                Texture texture2 = pRenderer.material.GetTexture("_Emissive");
                if ((object)texture1 != null)
                {
                    Debug.LogWarning((object)"RP: Found bumpmap texture, applying..");
                    material.SetTexture("_BumpMap", texture1);
                    material.SetTextureScale("_BumpMap", pRenderer.material.GetTextureScale("_BumpMap"));
                }
                if ((object)texture2 != null)
                {
                    Debug.LogWarning((object)"RP: Found heightmap texture, applying..");
                    material.SetTexture("_ParallaxMap", texture2);
                    material.SetFloat("_Parallax", (double)this.ParallaxHeight < 0.00499999988824129 || (double)this.ParallaxHeight > 0.0799999982118607 ? 0.02f : this.ParallaxHeight);
                    material.SetTextureScale("_Parallax", pRenderer.material.GetTextureScale("_Parallax"));
                }
                //try
                //{
                print("RP: Set _Shininess");
                material.SetFloat("_Shininess", (double)this.Shininess < 0.0 ? pRenderer.material.GetFloat("_Shininess") : this.Shininess);
                print("RP: Set _SpecColor");
                material.SetColor("_SpecColor", (double)this.SpecColorR < 0.0 ? pRenderer.material.GetColor("_SpecColor") : new Color(this.SpecColorR, this.SpecColorG, this.SpecColorB, this.SpecColorA));

                // -1 for ReflectionStrength will actually use ReflectionColor, Individual RGB(A???) values can be set in config.
                if (ReflectionStrength < 0f)
                {
                    print("RP: Set _ReflectColor: " + ReflectionColor.ToString());
                    material.SetColor("_ReflectColor", ReflectionColor);
                }
                else
                {
                    print("RP: Set _ReflectColor (ReflectionStrength: " + this.ReflectionStrength.ToString() + ")");
                    material.SetColor("_ReflectColor", new Color(this.ReflectionStrength, this.ReflectionStrength, this.ReflectionStrength, this.ReflectionStrength));
                }

                print("RP: Set _Color");
                material.SetColor("_Color", _Color);
                // rim lighting experiment. Useless for Unity reflective shaders; only the KSP versions have it. Disabled as it requires setting to KSP shaders.
                //material.SetFloat("_RimFalloff", rimFalloff);
                //material.SetColor("_RimColor", rimColor);

                //}
                //catch (Exception e)
                //{
                //    print("RP: ReplaceShader exception: " + e.ToString() + ": " + e.Message);
                //}
                // Add texture scale support
                material.mainTextureScale = pRenderer.material.mainTextureScale;

                pRenderer.material = material;
                ReflectiveScript reflectiveScript = this.part.gameObject.AddComponent<ReflectiveScript>();
                reflectiveScript.MatRenderer = pRenderer;
                reflectiveScript.CubemapSize = this.CubeMapSize;
                reflectiveScript.FarClipPlane = this.FarClipPlane;
                reflectiveScript.NearClipPlane = this.NearClipPlane;
                reflectiveScript.OneFacePerFrame = this.OneFacePerFrame;
                reflectiveScript.realTimeReflection = this.realTimeReflection;
                reflectiveScript.updateRate = this.updateRate;
                reflectiveScript.dirty = 7;
                this.reflectiveScript = reflectiveScript;
                Debug.Log((object)"RP: Material, shader and texture updated.");
            }
            else
                Debug.LogError((object)("RP: Unable to find a Renderer component on the part. Part: " + this.part.partName));
        }
		public void RefreshReflection(Vessel v)
		{
			this.reflectiveScript.dirty = 7;
		}
        public void Update()
        {
            scriptStatus = this.reflectiveScript.status;
            lastScene = this.reflectiveScript.lastScene;
        }

//        public override void OnUpdate()
//        {
//            base.OnUpdate();
//            this.lastScene = this.reflectiveScript.lastScene;
//            this.lastUpdate = this.reflectiveScript.lastUpdate;
//            this.scriptStatus = this.reflectiveScript.status;
//        }
    }
}
