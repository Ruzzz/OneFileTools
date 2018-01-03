#include <cstring>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include <zlib.h>

namespace impl {

template <typename Cont, typename Char>
Cont readFile(const Char *path)
{
    std::ifstream f;
    f.exceptions(std::ios::failbit | std::ios::badbit);
    f.open(path, std::ios::binary);
    f.seekg(0, std::ios::end);
    Cont out;
    size_t size = static_cast<size_t>(f.tellg());
    size_t count = size / sizeof(out[0]);
    size = count * sizeof(out[0]);
    out.resize(count);
    f.seekg(0, std::ios::beg);
    f.read(reinterpret_cast<char *>(&out[0]), size);
    return out;
}

template <typename Cont, typename Char>
void writeFile(const Char *path, const Cont &data)
{
    std::ofstream f;
    f.exceptions(std::ios::failbit | std::ios::badbit);
    f.open(path, std::ios::binary);
    size_t size = data.size() * sizeof(data[0]);
    f.write(reinterpret_cast<const char *>(&data[0]), size);
}

inline const size_t getBufSize(const size_t size)
{
    if (size <= 1024)
        return 1024;
    else if (size <= 16 * 1024)
        return 16 * 1024;
    else if (size <= 512 * 1024)
        return 512 * 1024;
    else if (size <= 2 * 1024 * 1024)
        return 2 * 1024 * 1024;
    else
        return 12 * 1024 * 1024;
}

// Return count of processed bytes of 'in'
template <typename ByteCont, typename InitFn, typename WorkFn, typename FinalFn>
size_t zlib_work(const ByteCont &in, ByteCont &out,
    InitFn fnInit, WorkFn fnWork, FinalFn fnFinal, bool isUnpack)
{
    if (in.size() == 0)
    {
        out.clear();
        return 0;
    }

    z_stream zs;
    std::memset(&zs, 0, sizeof(zs));
    if (fnInit(&zs) != Z_OK)
        throw std::runtime_error("init failed while (de)compressing");

    zs.next_in = const_cast<Bytef*>(reinterpret_cast<const Bytef*>(&in[0]));
    zs.avail_in = static_cast<uInt>(in.size());

    ByteCont tout;
    std::vector<char> buf;
    int code;
    buf.resize(getBufSize(in.size()));
    Bytef* const pBuf = reinterpret_cast<Bytef*>(&buf[0]);
    const uInt bufSize = static_cast<uInt>(buf.size());
        
    do
    {
        zs.next_out = pBuf;
        zs.avail_out = bufSize;
        code = fnWork(&zs, isUnpack ? Z_SYNC_FLUSH : Z_FINISH);
        if ((code == Z_OK) || (code == Z_STREAM_END))
        {
            if (tout.size() < zs.total_out)
                tout.append(&buf[0], zs.total_out - tout.size());
            // std::cout << "\e[A"
            std::cout << '\r' << std::to_string(zs.total_out) << ' ';
        }
    } while (code == Z_OK);
    
    fnFinal(&zs);
    std::cout << '\n';
    if (code != Z_STREAM_END)
    {
        std::string msg = "Exception during zlib (de)compression: ("
            + std::to_string(code) + ")";
        if (zs.msg != nullptr)
        {
            msg.push_back(' ');
            msg.append(zs.msg);
        }
        throw std::runtime_error(msg);
    }
    out.swap(tout);
    return static_cast<size_t>(zs.total_in);
}

inline int zlib_deflateInit(z_stream *zs)
{
    return ::deflateInit(zs, Z_BEST_COMPRESSION);
}

inline int zlib_inflateInit(z_stream *zs)
{
    return ::inflateInit(zs);
}

} // namespace impl

template <typename ByteCont>
inline size_t pack(const ByteCont &in, ByteCont &out)
{
    return impl::zlib_work(in, out, impl::zlib_deflateInit, ::deflate,
        ::deflateEnd, false);
}

template <typename ByteCont>
inline size_t unpack(const ByteCont &in, ByteCont &out)
{
    return impl::zlib_work(in, out, impl::zlib_inflateInit, ::inflate,
        ::inflateEnd, true);
}

// Main

struct AppOptions
{
    char *inPath;
    char *outPath;
    bool unpack;
};

bool parseAppOptions(int argc, char *argv[], AppOptions &options)
{
    if (argc == 3)
    {
        options.unpack = false;
        options.inPath = argv[1];
        options.outPath = argv[2];
    }
    else if ((argc == 4)
        && argv[1][0] == '-'
        && (argv[1][1] == 'd' || argv[1][1] == 'D')
        && argv[1][2] == 0)
    {
        options.unpack = true;
        options.inPath = argv[2];
        options.outPath = argv[3];
    }
    else
        return false;
    return true;
}

int main(int argc, char *argv[])
{
    AppOptions options;
    if (!parseAppOptions(argc, argv, options))
    {
        std::cout << "this.exe [-d] in out\n";
        return 0;
    }

    try
    {
        std::string in(impl::readFile<std::string>(options.inPath));
        std::string out;
        size_t processed;
        if (options.unpack)
        {
            processed = unpack(in, out);
            std::cerr << "Unpacked";
        }
        else
        {
            processed = pack(in, out);
            std::cerr << "Packed";
        }
        impl::writeFile(options.outPath, out);
        std::cerr << ": " << processed << " -> " << out.size() << '\n';
    }
    catch (const std::exception &e)
    {
        std::cerr << "Error: " << e.what() << '\n';
        return 1;
    }
    return 0;
}