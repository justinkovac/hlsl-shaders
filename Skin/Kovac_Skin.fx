/*

Creator:
Justin Kovac

Super Thanks:
Ben Cloward

Goals: 
-Create a simple skin shader that takes advantage of Oren/Nayar diffuse and Cook/Torrence specular.
-Emulate a faux SSS pass through usage of indirect lighting and transmission mask.
-Support for multiple light sources.
-Tweakable rim, spec, ambient and cubemap-based IBL.

Date: 
10/14/2012

*/

//-------------- 3D Studio Max Tweakable Objects --------------

//-------------- Color Tweakables --------------
float4 AmbientColor : Ambient
<
    string UIName = "Ambient Color";
> 

= {0.5f, 0.5f, 0.5f, 1.0f};

float4 DiffuseColor : Diffuse
<
    string UIName = "Diffuse Color";
> = {1.0f, 1.0f, 1.0f, 1.0f};

float4 SpecularColor : Specular
<
    string UIName = "Specular Color";
> = {1.0f, 1.0f, 1.0f, 1.0f};

float4 RimColor : RimColor
<
    string UIName = "Rim Color";
> = {1.0f, 1.0f, 1.0f, 1.0f};

float4 FresnelColor : FresnelColor
<
    string UIName = "Fresnel Color";
> = {1.0f, 1.0f, 1.0f, 1.0f};

float4 SSSColor : SSSColor
<
    string UIName = "SSS Color";
> = {1.0f, 1.0f, 1.0f, 1.0f};

float SpecularRoughness
<
	string UIWidget = "slider";
	float UIMin = 0.01;
	float UIMax = 1.0;
	float UIStep = 0.01;
	string UIName = "Specular Roughness";
> = 0.5;

float RimRoughness
<
	string UIWidget = "slider";
	float UIMin = 0.01;
	float UIMax = 1.0;
	float UIStep = 0.01;
	string UIName = "Rim Roughness";
> = 0.5;

float SSSMultiplier
<
	string UIWidget = "slider";
	float UIMin = 0.01;
	float UIMax = 10.0;
	float UIStep = 0.01;
	string UIName = "SSS Multiplier";
> = 0.5;

bool EnableSSS
<
	string UIWidget = "bool";
	string UIName = "Enable SSS";
> = true;

//-------------- Spinner Tweakables --------------

float RimPower
<
	string UIWidget = "slider";
	float UIMin = 0.01;
	float UIMax = 4.0;
	float UIStep = 0.1;
	string UIName = "Rim Power";
> = 1.0;

float FresnelPower
<
	string UIWidget = "slider";
	float UIMin = 0.01;
	float UIMax = 4.0;
	float UIStep = 0.1;
	string UIName = "Fresnel Power";
> = 1.0;

float LightAttenuation
<
	string UIWidget = "slider";
	float UIMin = 1.0;
	float UIMax = 10000.0;
	float UIStep = 1;
	string UIName = "Light Attenuation";
> = 2000.0;

//-------------- Texture Tweakables --------------

texture diffuseMap : DiffuseMap
<
    string name = "default_color.dds";
	string UIName = "Diffuse Texture";
    string TextureType = "2D";
>;

texture specularMap : SpecularMap
<
    string name = "default_color.dds";
	string UIName = "Specular Texture";
    string TextureType = "2D";
>;

texture normalMap : NormalMap
<
    string name = "default_bump_normal.dds";
	string UIName = "Normal Map";
    string TextureType = "2D";
>;

texture transmissionMask : TransmissionMask
<
    string name = "default_color.dds";
	string UIName = "Transmission Mask";
    string TextureType = "2D";
>;

texture cubeMap : EnvMap
<
    string name = "default_color.dds";
	string UIName = "Ambient Cube";
    string Type = "Cube";
>;

//-------------- Lighting Information --------------

float4 light1Pos : POSITION
<
	string UIName = "Light 1 Position";
	string Object = "PointLight";
	string Space = "World";
	int refID = 0;
> = {100.0f, 100.0f, 100.0f, 0.0f};


float4 light1Color : LIGHTCOLOR
<
	int LightRef = 0;
> = { 1.0f, 1.0f, 1.0f, 0.0f };

float4 light2Pos : POSITION
<
	string UIName = "Light 3 Position";
	string Object = "PointLight";
	string Space = "World";
	int refID = 1;
> = {100.0f, 100.0f, 100.0f, 0.0f};

float4 light2Color : LIGHTCOLOR
<
	int LightRef = 1;
> = { 1.0f, 1.0f, 1.0f, 0.0f };

float4 light3Pos : POSITION
<
	string UIName = "Light 3 Position";
	string Object = "PointLight";
	string Space = "World";
	int refID = 2;
> = {100.0f, 100.0f, 100.0f, 0.0f};

float4 light3Color : LIGHTCOLOR
<
	int LightRef = 2;
> = { 1.0f, 1.0f, 1.0f, 0.0f };


//-------------- Texture Sampler Declarations --------------

sampler2D diffuseMapSampler = sampler_state
{
	Texture = <diffuseMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Anisotropic;
	AddressU = Wrap;
	AddressV = Wrap;
};

sampler2D specularMapSampler = sampler_state
{
	Texture = <specularMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Anisotropic;
	AddressU = Wrap;
	AddressV = Wrap;
};

sampler2D normalMapSampler = sampler_state
{
	Texture = <normalMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Anisotropic;
};

sampler2D transmissionMaskSampler = sampler_state
{
	Texture = <transmissionMask>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Anisotropic;
	AddressU = Wrap;
	AddressV = Wrap;
};

samplerCUBE cubeMapSampler = sampler_state
{
	Texture = <cubeMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Anisotropic;
	AddressU = Wrap;
	AddressV = Wrap;
};


//-------------- 3D Studio Max Transformations --------------

float4x4 World      		: WORLD;			
float4x4 WorldIT			: WORLDIT;			
float4x4 WorldViewProj 		: WORLDVIEWPROJ;	
float4x4 ViewI				: VIEWI;			
float4x4 ViewIT				: VIEWIT;			

//-------------- Vertex and Pixel Definititions --------------

//-------------- Application to Vertex --------------

struct a2v {
	float4 position		: POSITION;
	float2 texCoord		: TEXCOORD0;
	float3 normal		: NORMAL;
	float3 binormal		: BINORMAL;
	float3 tangent		: TANGENT;

};

//-------------- Vertex to Pixel --------------

struct v2f {
	float4 position    		: POSITION;
	float2 texCoord    		: TEXCOORD0;
	float3 lightVec   		: TEXCOORD1;
	float3 eyeVec   		: TEXCOORD2;
	float3 worldNormal		: TEXCOORD3;
	float3 worldBinormal	: TEXCOORD4;
	float3 worldTangent		: TEXCOORD5;

};

//-------------- Cook-Torrance Specular --------------

float CookTorrance(float NdotL, float NdotV, float NdotH, float VdotH, float SpecularRoughness, float RimRoughness)
{
	SpecularRoughness *= 3.0f;
	
	// Geometric term based on Ben Cloward
	float G1 = (2.0f * NdotH * NdotV) / VdotH;
	float G2 = ( 2.0f * NdotH * NdotL ) / VdotH;
	float G = min( 1.0f, max( 0.0f, min( G1, G2 ) ) );
  
	// Compute the Rim
	float F = RimRoughness + ( 1.0f - RimRoughness ) * pow( 1.0f - NdotV, 5.0f );
  
	// Compute the roughness term
	float R_2 = SpecularRoughness * SpecularRoughness;
	float NDotH_2 = NdotH * NdotH;
	float A = 1.0f / ( 4.0f * R_2 * NDotH_2 * NDotH_2 );
	float B = exp( -( 1.0f - NDotH_2 ) / ( R_2 * NDotH_2 ) );
	float R = A * B;
	
	return ( ( G * F * R ) / ( NdotL * NdotV ) );
}

//-------------- Vertex Shader --------------

v2f vertexShader(a2v IN, uniform float4 LightPosition)
{
	v2f OUT;
	
	OUT.worldNormal = normalize(mul(IN.normal, WorldIT).xyz);
	OUT.worldTangent = normalize(mul(IN.tangent, WorldIT).xyz);
	OUT.worldBinormal = normalize(mul(IN.binormal, WorldIT).xyz);
	
	float3 worldSpacePos = mul(IN.position, World);
	OUT.texCoord = IN.texCoord;
	OUT.lightVec = LightPosition - worldSpacePos;
	OUT.eyeVec = ViewI[3].xyz - worldSpacePos;
	OUT.position = mul(IN.position, WorldViewProj);
	
	return OUT;
}

//-------------- Pixel Shader --------------

float4 pixelShader(v2f IN, uniform float4 LightColor) : COLOR
{
	// Texture Maps
	float4 DiffuseMap = tex2D(diffuseMapSampler, IN.texCoord.xy);
	float4 SpecularMap = tex2D(specularMapSampler, IN.texCoord.xy);
	float4 TransmissionMask = tex2D(transmissionMaskSampler, IN.texCoord.xy);
	float3 NormalMap = tex2D(normalMapSampler, IN.texCoord).xyz * 2.0 - 1.0;
	
    // Create tangent-space vectors
    float3 Nn = IN.worldNormal;
    float3 Bn = IN.worldBinormal;
    float3 Tn = IN.worldTangent;
  
	// Convert Normal Map to World Space
    float3 N = (NormalMap.z * Nn) + (NormalMap.x * Bn + NormalMap.y * -Tn);	
	float3 worldNorm = N.xzy;
	
	// Diffusely convolved cubemap
	float4 EnvMap = texCUBE(cubeMapSampler, worldNorm);
	
	// Declare View, Light and Normal Vectors
	float3 L  = normalize(IN.lightVec.xyz);
	float3 V  = normalize(IN.eyeVec.xyz);
	float3 H = normalize(L + V);
	float3 NdotL = dot(N, L);
	float NdotH = dot(N, H);
	float NdotV = dot(N, V);
	float VdotH = dot(V, H);
	
	// Specular
	float4 Specular =  CookTorrance(NdotL, NdotV, NdotH, VdotH, SpecularRoughness, RimRoughness) * SpecularColor * SpecularMap;
	
	// Lighting
	float diffuseLight = saturate(NdotL);
	
	// Rim
	float3 Rim = (float3)(1.0f - max(0.0f, dot(N, L)));
	Rim *= pow(Rim, RimPower);
	Rim *= RimColor;
	
	// Fresnel
	float3 Fresnel = (float3)(1.0f - max(0.0f, dot(N, V)));
	Fresnel *= pow(Fresnel, FresnelPower);
	Fresnel *= FresnelColor + EnvMap;

	// SSS
	//float4 SSSColor = float4(1,1,1,0);
	if(EnableSSS)
	{
    	float SSSInterpolation = pow(max(dot(-V, L), 0), 2);
		SSSColor = lerp(float4(0, 0, 0, 1), SSSColor, SSSInterpolation) * TransmissionMask * SSSMultiplier;
	}
	
	
	// Light Attenuation
    float D = length(IN.lightVec.xyz);
    float Atten = (1 / (D * D)) * LightAttenuation;
    half Atten2 = Atten * 2;
	float lightAtten = LightColor * Atten2;
	
	// Final Combine
	float4 Diffuse = DiffuseMap * DiffuseColor + SSSColor;
	float4 Ambient = AmbientColor * DiffuseMap;
	Ambient.rgb *= (Rim * LightColor) * EnvMap + Fresnel + SSSColor;

	LightColor *= lightAtten;

	return LightColor * diffuseLight * (Diffuse + Specular ) + Ambient;
	//return SSSColor;
}

//-------------- Techniques --------------

technique SkinShader
{ 
    pass one 
    {		
	VertexShader = compile vs_3_0 vertexShader(light1Pos);										
	ZEnable 			= true;
	ZWriteEnable 		= true;
	AlphaBlendEnable	= false;
												
	PixelShader = compile ps_3_0 pixelShader(light1Color);
	}
	
	pass two 
    {		
	VertexShader = compile vs_3_0 vertexShader(light2Pos);										
	ZEnable 			= true;
	ZWriteEnable 		= false;
	AlphaBlendEnable	= true;
	SrcBlend 			= One;
	DestBlend 			= One;												
	PixelShader = compile ps_3_0 pixelShader(light2Color);
	}
}