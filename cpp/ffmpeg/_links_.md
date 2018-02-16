Build
-----

- http://howto-pages.org/ffmpeg/#build


Static link
-----------

- https://www.ffmpeg.org/doxygen/trunk/allcodecs_8c_source.html
- [FFMPEG_DIR]/libavcodec/allcodecs.c

Minimize size. Use only needed:

    // avcodec_register_all()

    extern "C"
    {
        extern AVCodec ff_XXX_encoder;
        extern AVCodec ff_XXX_decoder;
        extern AVCodecParser ff_XXX_parser;
        ...
    }


    avcodec_register(ff_XXX_encoder)
    avcodec_register(ff_XXX_decoder)
    av_register_codec_parser(ff_XXX_parser)
    
    av_register_bitstream_filter(ff_XXX_bsf)  // bitstream filters
    av_register_hwaccel(ff_XXX_hwaccel)  // hardware accelerators
 
    av_register_input_format (AVInputFormat *)
    av_register_output_format (AVOutputFormat *)
    av_ffurl_register_protocol(URLProtocol *protocol, int size)
    avformat_network_init()
    avformat_network_deinit()
 
Example:

    extern "C"
    {
        extern AVCodec ff_libx264_encoder;
        extern AVCodec ff_h264_decoder;
        extern AVCodecParser ff_h264_parser;
    }

    avcodec_register(&ff_libx264_encoder);
    avcodec_register(&ff_h264_decoder);
    av_register_codec_parser(&ff_h264_parser);
