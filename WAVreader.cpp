#include <iostream>
#include <string>
#include <fstream>

using namespace std;
struct WAV_HDR{
	char 	RIFF[4];
	long 	ChunckSize;
	char 	WAVE[4];
	char 	SubChunk1ID[4];
	long 	SubChunk1Size;
	short 	AudioFormat;
	short 	NumChannels;
	long 	SampleRate;
	long 	ByteRate;
	short 	BlockAlign;
	short 	BitsPerSample;
	char 	SubChunk2ID[4];
	long 	SubChunk2Size;
};

int main(){
	WAV_HDR wavHeader;
	FILE *wavFILE;
	wavFILE = fopen( "Service-bell.wav", "rb");
	
	int headerSize = sizeof(WAV_HDR);
	int filelength = 0;
	/*char ch;

	Wav_Header wavHeader;
	
	ifstream WAVfile; 
	WAVfile.open("Service-bell.wav");*/
	if (wavFILE == NULL){
		printf("could not open file \n");
		exit(EXIT_FAILURE);
	}
	else
	{
		printf("successful open \n");
		
	}

	fread(&wavHeader, 1, headerSize, wavFILE);

	//cout << wavHeader.RIFF[0] << wavHeader.RIFF[1] << wavHeader.RIFF[2] << wavHeader.RIFF[3] << endl;

	//cout << wavHeader.ChunckSize << endl;

	cout << wavHeader.WAVE[0] << endl;

	//cout << wavHeader.SubChunk1ID << endl;

	cout << wavHeader.SubChunk1Size << endl;

	/*
	fread(&wavHeader);
	cout << wavheader.RIFF;

	WAVfile.close();
	return 0;*/


	
}