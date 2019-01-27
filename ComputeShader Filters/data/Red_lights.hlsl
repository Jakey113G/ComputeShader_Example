struct Pixel
{
    int colour;
};

StructuredBuffer<Pixel> Buffer0 : register(t0);
RWStructuredBuffer<Pixel> BufferOut : register(u0);

float4 readPixel(int x, int y)
{
	float4 output;
	uint index = (x + y * 1024);
	
	output.x = (float)(((Buffer0[index].colour ) & 0x000000ff)      ) / 255.0f; 
	output.y = (float)(((Buffer0[index].colour ) & 0x0000ff00) >> 8 ) / 255.0f;
	output.z = (float)(((Buffer0[index].colour ) & 0x00ff0000) >> 16) / 255.0f;
	output.w = (float)(((Buffer0[index].colour ) & 0xff000000) >> 24) / 255.0f;
	
	return output;
}

float4 readOutputPixel(int x, int y)
{
	float4 output;
	uint index = (x + y * 1024);
	
	output.x = (float)(((BufferOut[index].colour ) & 0x000000ff)      ) / 255.0f; 
	output.y = (float)(((BufferOut[index].colour ) & 0x0000ff00) >> 8 ) / 255.0f;
	output.z = (float)(((BufferOut[index].colour ) & 0x00ff0000) >> 16) / 255.0f;
	output.w = (float)(((BufferOut[index].colour ) & 0xff000000) >> 24) / 255.0f;
	
	return output;
}

void writeToPixel(int x, int y, float4 colour)
{
	uint index = (x + y * 1024);
	
	int ired   = (int)(clamp(colour.r,0,1) * 255);
	int igreen = (int)(clamp(colour.g,0,1) * 255) << 8;
	int iblue  = (int)(clamp(colour.b,0,1) * 255) << 16;
	int ialpha = (int)(clamp(colour.a,0,1) * 255) << 24;
	
    BufferOut[index].colour = ired + igreen + iblue + ialpha;
}

[numthreads(32, 16, 1)]
void CSMain( uint3 dispatchThreadID : SV_DispatchThreadID )
{
	int x = dispatchThreadID.x;
	int y = dispatchThreadID.y;
	
	float4 colouredPixel = {0.0, 0.0, 1.0, 1.0};	
	//float4 colouredPixel;
	//colouredPixel[0] = 0.0;	//b
	//colouredPixel[1] = 0.0;	//g
	//colouredPixel[2] = 1.0; //r	
	//colouredPixel[3] = 1.0; //a

	bool isBright = readOutputPixel(x,y).r > 0.9 && readOutputPixel(x,y).g > 0.9 && readOutputPixel(x,y).b > 0.9;
	if( readOutputPixel(x,y).a < 0.5 && isBright )
		writeToPixel(dispatchThreadID.x, dispatchThreadID.y, colouredPixel);
		
	GroupMemoryBarrierWithGroupSync();
}
