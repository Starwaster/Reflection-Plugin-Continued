Reflection-Plugin-Continued
===========================

This is an updated version of the Reflection Plugin created by Razchek with some additional features and fixes that provide more control over reflective materials and non-realtime updating for performance increases.

Example Usage:
MODULE
    {
        name = ReflectiveShaderModule

        // Lower values for performance, higher values for aesthetics (you shouldn't ever need to go higher than 1024).
        CubeMapSize = 128

        // How deep the reflection will be ("how far the reflection camera will view")
        FarClipPlane = 500000000
		// How far away must something be before it is reflected
		//NearClipPlane = 1

        // Set to false to render all 6 faces of the CubeMap at once (six times slower~)
        OneFacePerFrame = true

        // The shader to find. The reflective shaders are:
        // Reflective/Diffuse
        // Reflective/Specular
        // Reflective/VertexLit
        // Reflective/Bumped Diffuse
        // Reflective/Bumped Specular
        // Reflective/Bumped Unlit
        // Reflective/Bumped VertexLit
        // Reflective/Parallax Diffuse
        // Reflective/Parallax Specular 
        ShaderName = Reflective/Bumped
	      realTimeReflection = False
	      updateRate = 300
		

        // The height of the parallax map. Values are accepted between 0.005 and 0.08.
        ParallaxHeight = 0.005

        // How reflective the reflection will be (Weakest 0.0 - 1.0 Strongest).
        ReflectionStrength = 1.0
	      //ReflectionColor = 0, 0, 0, 0

        // Use this variable to specify which meshes to apply the shader to.
        // Not using this variable will default to the first found mesh.
        // Use the actual mesh name for the value. Or you could use:
        // all - to replace the shader on all meshes in the model.
        //MeshesToChange = polymsh,polymsh_detached,polymsh_detached1

        // How shiny the specularity will be (if specular).
        // This value will be automatically set if it already exists on the previous shader and is not defined here.
        Shininess = 1.0

        // These variables should be used together only.
        // These values will be automatically set if they already exist on the previous shader and are not defined here
        //SpecColorR = 0.5
        //SpecColorG = 0.5
        //SpecColorB = 0.5
        //SpecColorA = 0.5
    }
