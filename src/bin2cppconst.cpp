#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>


const unsigned int NUM_BYTES_PER_LINE = 8;
const char USAGE[] =
{
    "bin2cppconst v0.1a by Ruzzz\n"
    "Convert binary file to .cpp source file"
        " with 'const unsigned char[]' inside.\n"
    "Usage: bin2cppconst bin-file [xor-byte] [bytes-per-line = 8]\n"
    "\n"
    "  xor-byte                - If not 0 then xor apply to each byte.\n"
    "  bytes-per-line          - Number of bytes in line.\n"
    "\n"
    "Note: It is not optimized version, use for small files only.\n"
    "Add cpp file to project and use 'extern const unsigned char'"
        " to access from other files.\n"
};


int main(int argc, char const *argv[])
{
    if (argc < 2 || argc > 4)
    {
        std::cout << USAGE;
        return 1;
    }
    else
    {
        unsigned int bytesPerLine = argc == 4 ? std::atoi(argv[3]) : NUM_BYTES_PER_LINE;
        unsigned int xorValue = argc == 3 ? std::atoi(argv[2]) : 0;
        unsigned int fileSize;
        std::vector<unsigned char> content;

        {
            std::ifstream fin(argv[1], std::ios::binary | std::ios::ate);
            if (!fin.good())
                return 1;
            fileSize = static_cast<unsigned int>(fin.tellg());
            fin.seekg(0);
            // Read file to buffer
            content.reserve(fileSize);
            fin.read(reinterpret_cast<char*>(&content[0]), fileSize);
        }

        std::string outFileName(argv[1]);
        outFileName += ".cpp";
        std::ofstream fout(outFileName.c_str());
        fout << "const unsigned char FILE[" << fileSize << "] = {\n";

        fout.setf(std::ios::hex, std::ios::basefield);
        fout.setf(std::ios::uppercase);
        fout.fill('0');

        for (unsigned int i = 0; i < fileSize; ++i)
        {
            fout << "0x";
            unsigned int value = static_cast<unsigned int>(content[i]);
            if (xorValue > 0)
                value = value ^ xorValue;
            fout.width(2);
            fout << value;
            if (i != fileSize - 1)
            {
                if (i % bytesPerLine == bytesPerLine - 1)
                    fout << ",\n";
                else
                    fout << ", ";
            }
        }

        fout << " };\n";
    }

    return 0;
}
