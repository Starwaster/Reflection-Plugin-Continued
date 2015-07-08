using UnityEngine;

namespace ReflectionPlugin
{
	public class ProcCubeMap : ProceduralCubemap
	{
		ProcCubeMap()
		{
		}
	}

	public class ReflectiveScript : MonoBehaviour
	{
		public static int i = 0;
		public int CubemapSize = 128;
		public Material currentMaterial;
		public float FarClipPlane = float.MaxValue;
		public float NearClipPlane = -1f;
		public Renderer MatRenderer;
		public bool OneFacePerFrame;
		public bool realTimeReflection = true;
		public double updateRate = 0.0;
		public int dirty = 7;
		//private int maskBit;
		
		private Camera _cam;
		private RenderTexture _rtex;
		private GameObject _go;
		public string status = "";
		private string renderResult = "PRE-INITIALIZATION";
		//private int maskBit = 12;
		public string lastScene = "NOWHERE";
		private double lastUpdate = double.MinValue;
		private float lastRealUpdate;
		
		private void Start()
		{
			//currentMaterial = renderer.material;
			for(int i = 0; i < 31; i++)
				Debug.Log (" Layer " + i.ToString () + ": " + LayerMask.LayerToName(i));
			UpdateCubemap(63);
			dirty = 7;
		}

		private bool ShouldUpdate()
		{
			if (realTimeReflection || dirty > 0)
			{
				return true;
			}
			else if ( Planetarium.GetUniversalTime() >= lastUpdate + updateRate && (Time.time > lastRealUpdate + 5f))
			{
				dirty = 6;
				return true;
			}
			else
			{
				string scene = "";
				//if (HighLogic.LoadedSceneIsEditor)
				//    scene = "editor";
				if (HighLogic.LoadedSceneIsFlight)
				{
					scene = FlightGlobals.currentMainBody.name;
				}
				if (scene != lastScene)
				{
					dirty = 7;
					lastScene = scene;
					return true;
				}
			}
			return false;
		}

		protected void FixedUpdate()
		{
			_cam.transform.position = _go.transform.position = transform.position;
		}
		
		protected void LateUpdate()
		{
			if (ShouldUpdate())
			{
				if (OneFacePerFrame && dirty < 7)
				{
					//_cam.cullingMask = maskBit;
					UpdateCubemap(1 << Time.frameCount % 6);
				}
				else
				{
					//_cam.cullingMask = maskBit;
					UpdateCubemap(63);
				}
			}
			else
				status = renderResult + ((lastUpdate + updateRate) - Planetarium.GetUniversalTime()).ToString();
		}

/*
Layer 0: Default
Layer 1: TransparentFX
Layer 2: Ignore Raycast
Layer 3: 
Layer 4: Water
Layer 5: UI
Layer 6: 
Layer 7: 
Layer 8: PartsList_Icons
Layer 9: Atmosphere
Layer 10: Scaled Scenery
Layer 11: UI_Culled
Layer 12: UI_Main
Layer 13: UI_Mask
Layer 14: Screens
Layer 15: Local Scenery
Layer 16: kerbals
Layer 17: Editor_UI
Layer 18: SkySphere
Layer 19: Disconnected Parts
Layer 20: Internal Space
Layer 21: Part Triggers
Layer 22: KerbalInstructors
Layer 23: ScaledSpaceSun
Layer 24: MapFX
Layer 25: EzGUI_UI
Layer 26: WheelCollidersIgnore
Layer 27: WheelColliders
Layer 28: TerrainColliders
Layer 29: DragRender
Layer 30: SurfaceFX
*/		

		protected void UpdateCubemap(int faceMask)
		{

			if ((object)_cam == null) 
			{
				_go = new GameObject("CubemapCamera" + i.ToString ());
				_go.AddComponent(typeof(Camera));
				_go.hideFlags = HideFlags.HideAndDontSave;
				_go.transform.position = transform.position;
				_go.transform.rotation = Quaternion.identity;
				_go.camera.clearFlags = CameraClearFlags.Skybox;
				_go.camera.renderingPath = RenderingPath.UsePlayerSettings;
				_go.camera.depth = Camera.main.depth + 1;
				_go.camera.aspect = 1;
				float[] distances = new float[32];

				distances[10] = 3.0E+07F;
				distances[15] = 3.0E+07F;

				_go.camera.layerCullDistances = distances;

				//_go.camera.cullingMask = LayerMask. //(1 << 0) | (1 << 4) | (1 << 9) | (1 << 10) | (1 << 15) | (1 << 18) | (1 << 23);
				_cam = _go.camera;
				_cam.nearClipPlane = NearClipPlane;
				_cam.farClipPlane = FarClipPlane;
				_cam.enabled = false;
				i += 1;
			}


			/*
			if (!(bool)((UnityEngine.Object)_cam))
			{
				GameObject gameObject1 = new GameObject("CubemapCamera", new System.Type[1] { typeof(Camera) });
				gameObject1.hideFlags = HideFlags.HideAndDontSave;
				GameObject gameObject2 = gameObject1;
				gameObject2.transform.position = transform.position;
				gameObject2.transform.rotation = Quaternion.identity;
				_cam = gameObject2.camera;
				//_cam.hdr = true;
				_cam.depth = Camera.main.depth + 1;//Camera.main.depth + 1;
				_cam.farClipPlane = FarClipPlane;
				_cam.enabled = false;
				_cam.cullingMask = (1 << 0) | (1 << 4) | (1 << 9) | (1 << 10) | (1 << 15) | (1 << 18) | (1 << 23);
				//_cam.cullingMask = (1 << maskBit);
				//_cam.layerCullSpherical = true;
				if (NearClipPlane > 0f)
					_cam.nearClipPlane = NearClipPlane;
				for (int i = 0; i < 32; i++)
				{
					_cam.layerCullDistances[i] = int.MaxValue;
				}
				status = _cam.cullingMask.ToString();
			}
			 */
			if ((object)_rtex == null)
			{
				ReflectiveScript reflectiveScript = this;
				RenderTexture renderTexture1 = new RenderTexture(CubemapSize, CubemapSize, 16);
				renderTexture1.isCubemap = true;
				renderTexture1.isPowerOfTwo = true;
				renderTexture1.hideFlags = HideFlags.HideAndDontSave;
				renderTexture1.useMipMap = true;
				renderTexture1.wrapMode = TextureWrapMode.Clamp;
				RenderTexture renderTexture2 = renderTexture1;
				_cam.backgroundColor = Color.black;

				reflectiveScript._rtex = renderTexture2;
				//MatRenderer.sharedMaterial.SetTexture("_Cube", (Texture)_rtex);
				foreach (Renderer r in GetComponentsInChildren<Renderer>())
				{
					foreach (Material m in r.sharedMaterials)
					{
						if (m.HasProperty("_Cube"))
						{
							m.SetTexture("_Cube", _rtex);
						}
					}
				}
			}
			if ((object)_cam == null)
				Debug.Log ("_cam null");
			if ((object)_rtex == null)
				Debug.Log ("_rtex null");
			if ((object)_go == null)
				Debug.Log ("_go null");


			_cam.transform.position = transform.position;
			if (_cam.RenderToCubemap(_rtex, faceMask))
			{
				//Debug.Log ("Checking time");
				lastUpdate = Planetarium.GetUniversalTime();
				lastRealUpdate = Time.time;
				//Debug.Log ("Setting material");
				//currentMaterial.SetTexture ("_Cube", _rtex);
				//renderer.material = currentMaterial;
				renderResult = "Success: (next)";
				if (dirty > 0)
				{
					if (faceMask == 63)
						dirty = 0;
					else
					{
						dirty -= 1;
					}
				}
			}
			else
				renderResult = "Failure: (next)";
			//Debug.Log ("Result = " + renderResult);
		}
		private void OnDisable()
		{
			UnityEngine.Object.DestroyImmediate((UnityEngine.Object)_cam);
			UnityEngine.Object.DestroyImmediate((UnityEngine.Object)_rtex);
			UnityEngine.Object.DestroyImmediate((UnityEngine.Object)_go);
		}
	}
}
