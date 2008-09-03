#include "PUIDGenerator.h"

/* constructors */
PUIDGenerator::PUIDGenerator(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
PUIDGenerator::~PUIDGenerator() {
}

/* methods */
const string &PUIDGenerator::generatePUID(const string &filename, int filetype) {
	puid.clear();
	AVCodec *codec;
	switch (filetype) {
		case FILETYPE_UNDEFINED:
			return puid;

		case FILETYPE_OGG_VORBIS:
			codec = avcodec_find_decoder(CODEC_ID_VORBIS);
			break;

		case FILETYPE_OGG_FLAC:
		case FILETYPE_FLAC:
			codec = avcodec_find_decoder(CODEC_ID_FLAC);
			break;

		case FILETYPE_OGG_SPEEX:
			break;

		case FILETYPE_MPEG:
			codec = avcodec_find_decoder(CODEC_ID_MP3);
			break;

		case FILETYPE_MPC:
			codec = avcodec_find_decoder(CODEC_ID_MUSEPACK7);
			break;

		case FILETYPE_WAVPACK:
			codec = avcodec_find_decoder(CODEC_ID_WAVPACK);
			break;

		case FILETYPE_TRUEAUDIO:
			codec = avcodec_find_decoder(CODEC_ID_TTA);
			break;
	}
	if (!codec) {
		ostringstream error;
		error << "Codec not found for filetype " << filetype << ". File: " << filename;
		locutus->debug(DEBUG_NOTICE, error.str());
		return puid;
	}

	AVCodecContext *c = avcodec_alloc_context();

	/* open it */
	if (avcodec_open(c, codec) < 0) {
		av_free(c);                                                                                                                                    
		ostringstream error;
		error << "Unable to open codec for filetype " << filetype << ". File: " << filename;
		locutus->debug(DEBUG_NOTICE, error.str());
		return puid;
	}

	FILE *f = fopen(filename.c_str(), "rb");
	if (!f) {
		avcodec_close(c);
		av_free(c);                                                                                                                                    
		ostringstream error;
		error << "Unable to open file: " << filename;
		locutus->debug(DEBUG_NOTICE, error.str());
		return puid;
	}
	FILE *outfile = fopen("/tmp/locutus.tmp.wav", "wb"); // FIXME: configurable tmp location
	if (!outfile) {
		fclose(f);
		avcodec_close(c);
		av_free(c);                                                                                                                                    
		locutus->debug(DEBUG_NOTICE, "Unable to open temporary file");
		return puid;
	}

	/* decode until eof */
	uint8_t inbuf[INBUF_SIZE + FF_INPUT_BUFFER_PADDING_SIZE];
	uint8_t *inbuf_ptr = inbuf;
	uint8_t *outbuf = new uint8_t[AVCODEC_MAX_AUDIO_FRAME_SIZE];
	for(;;) {
		int size = fread(inbuf, 1, INBUF_SIZE, f);
		if (size == 0)
			break;

		inbuf_ptr = inbuf;
		while (size > 0) {
			int out_size;
			int len = avcodec_decode_audio2(c, (short *)outbuf, &out_size,
					inbuf_ptr, size);
			if (len < 0) {                                                                                                                             
				fprintf(stderr, "Error while decoding\n");
				exit(1);
			}
			if (out_size > 0) {
				/* if a frame has been decoded, output it */
				fwrite(outbuf, 1, out_size, outfile);
			}
			size -= len;
			inbuf_ptr += len;
		}
	}

	fclose(outfile);
	fclose(f);
	delete [] outbuf;

	avcodec_close(c);
	av_free(c);

	return puid;
}

void PUIDGenerator::loadSettings() {
}
