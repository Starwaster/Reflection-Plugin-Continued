using UnityEngine;

namespace ReflectionPlugin
{
	public class ReflectiveScript : MonoBehaviour
	{
		public int CubemapSize = 128;
		public float FarClipPlane = 100f;
		public float NearClipPlane = -1f;
		public Renderer MatRenderer;
		public bool OneFacePerFrame;
		public bool realTimeReflection = true;
		public double updateRate = 0.0;
		public int dirty = 7;
		//private int maskBit;
		
		private Camera _cam;
		private RenderTexture _rtex;
		public string status = "";
		private string renderResult = "PRE-INITIALIZATION";
		//private int maskBit = 12;
		public string lastScene = "NOWHERE";
		private double lastUpdate = double.MinValue;
		private float lastRealUpdate;
		
		private void Start()
		{
			this.UpdateCubemap(63);
		}

		private bool ShouldUpdate()
		{
			if (realTimeReflection || this.dirty > 0)
			{
				return true;
			}
			else if ( Planetarium.GetUniversalTime() >= this.lastUpdate + this.updateRate && (Time.time > this.lastRealUpdate + 5f))
			{
				this.dirty = 6;
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
				if (scene != this.lastScene)
				{
					this.dirty = 7;
					this.lastScene = scene;
					return true;
				}
			}
			return false;
		}
		
		
		
		private void OnPostRender()
		{
			if (ShouldUpdate())
			{
				if (OneFacePerFrame && this.dirty < 7)
				{
					//this._cam.cullingMask = maskBit;
					this.UpdateCubemap(1 << Time.frameCount % 6);
				}
				else
				{
					//this._cam.cullingMask = maskBit;
					this.UpdateCubemap(63);
				}
			}
			else
				status = renderResult + ((lastUpdate + this.updateRate) - Planetarium.GetUniversalTime()).ToString();
		}

		private void UpdateCubemap(int faceMask)
		{
			if (!(bool)((UnityEngine.Object)this._cam))
			{
				GameObject gameObject1 = new GameObject("ReflectionCamera", new System.Type[1] { typeof(Camera) });
				gameObject1.hideFlags = HideFlags.HideAndDontSave;
				GameObject gameObject2 = gameObject1;
				gameObject2.transform.position = this.transform.position;
				gameObject2.transform.rotation = Quaternion.identity;
				this._cam = gameObject2.camera;
				this._cam.hdr = true;
				this._cam.depth = Camera.main.depth + 1;
				this._cam.farClipPlane = this.FarClipPlane;
				this._cam.enabled = false;
				this._cam.cullingMask = (1 << 0) | (1 << 4) | (1 << 9) | (1 << 10) | (1 << 15) | (1 << 18) | (1 << 23);
				//this._cam.cullingMask = (1 << maskBit);
				this._cam.layerCullSpherical = true;
				if (this.NearClipPlane > 0f)
					this._cam.nearClipPlane = this.NearClipPlane;
				for (int i = 0; i < 32; i++)
				{
					this._cam.layerCullDistances[i] = int.MaxValue;
				}
				//                               -1                                              -False                              True
				//this.status = this._cam.cullingMask.ToString();
				//this._cam.cullingMask = 32771;
			}
			if (!(bool)((UnityEngine.Object)this._rtex))
			{
				ReflectiveScript reflectiveScript = this;
				RenderTexture renderTexture1 = new RenderTexture(this.CubemapSize, this.CubemapSize, 16);
				renderTexture1.isCubemap = true;
				renderTexture1.hideFlags = HideFlags.HideAndDontSave;
				RenderTexture renderTexture2 = renderTexture1;
				reflectiveScript._rtex = renderTexture2;
				this.MatRenderer.sharedMaterial.SetTexture("_Cube", (Texture)this._rtex);
			}
			this._cam.transform.position = this.transform.position;
			if (this._cam.RenderToCubemap(this._rtex, faceMask))
			{
				this.lastUpdate = Planetarium.GetUniversalTime();
				this.lastRealUpdate = Time.time;
				renderResult = "Success: (next)";
				if (this.dirty > 0)
				{
					if (faceMask == 63)
						this.dirty = 0;
					else
					{
						this.dirty -= 1;
					}
				}
			}
			else
				renderResult = "Failure: (next)";
		}
		private void OnDisable()
		{
			UnityEngine.Object.DestroyImmediate((UnityEngine.Object)this._cam);
			UnityEngine.Object.DestroyImmediate((UnityEngine.Object)this._rtex);
		}
	}
}
