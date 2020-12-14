#include <fstream>
#include <memory>
#include <iterator>
#include <vector>
#include <iostream>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "tapasco.hpp"

#define PE_ID 1744

#define BRAM_SIZE 0x10000
#define PROGRAM_BRAM_SIZE (BRAM_SIZE - (BRAM_SIZE / 4))

using namespace std;
using namespace tapasco;

void read_binary_file(std::string filename, std::vector<char> &buffer) {
    int fd = open(filename.c_str(), O_RDONLY);
    struct stat sb;
    fstat(fd, &sb);
    char *buf = (char*)mmap(NULL, sb.st_size, PROT_READ, MAP_SHARED, fd, 0);
    buffer.insert(buffer.end(), buf, buf + sb.st_size);
    munmap(buf, sb.st_size);
    close(fd);
    std::cout << "Finished reading binary file. Received " << buffer.size() << " bytes." << std::endl;
}

int main(int argc, char** argv)
{
    if(argc < 2)
    {
        printf("Missing program code, exiting...");
        exit(1);
    }
    
    Tapasco tapasco;

    std::vector<char> program_buffer;
    read_binary_file(argv[1], program_buffer);

    if (program_buffer.size() > PROGRAM_BRAM_SIZE) {
        std::cout << "ERROR: Program exceeds BRAM size." << std::endl;
        exit(1);
    }

    // Wrap the program buffer into local memory object
    auto program_buffer_in = makeLocal(makeInOnly(
            makeWrappedPointer(program_buffer.data(), program_buffer.size())
        ));

    uint64_t fpga_sum = -1;
    RetVal<uint64_t> retval(&fpga_sum);
    int a = 42;
    int b = 1337;
    auto job = tapasco.launch(PE_ID,
                                retval, // return value
                                program_buffer_in,
                                a, // Arg 1
                                b  // Arg 2
                             );
    cout << "Waiting for RISC-V " << endl;
    job();
    cout << "RISC-V return value: " << fpga_sum << endl;
    
    return 0;
}
