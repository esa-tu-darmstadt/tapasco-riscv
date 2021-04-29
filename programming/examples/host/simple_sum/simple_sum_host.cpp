#include "tapasco.hpp"
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <iterator>
#include <memory>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <vector>

#define PE_ID 1748

#define BRAM_SIZE 0x10000
#define PROGRAM_BRAM_SIZE (BRAM_SIZE - (BRAM_SIZE / 4))

using namespace std;
using namespace tapasco;

void read_binary_file(std::string filename, std::vector<char> &buffer) {
    int fd = open(filename.c_str(), O_RDONLY);
    struct stat sb;
    fstat(fd, &sb);
    char *buf = (char *)mmap(NULL, sb.st_size, PROT_READ, MAP_SHARED, fd, 0);
    buffer.insert(buffer.end(), buf, buf + sb.st_size);
    munmap(buf, sb.st_size);
    close(fd);
    std::cout << "Finished reading binary file. Received " << buffer.size() << " bytes." << std::endl;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Missing program code, exiting...");
        exit(1);
    }

    int peID = PE_ID;

    if (argc > 2) {
        peID = atoi(argv[2]);
    }

    Tapasco tapasco;

    std::vector<char> program_buffer;
    read_binary_file(argv[1], program_buffer);

    if (program_buffer.size() > PROGRAM_BRAM_SIZE) {
        std::cout << "ERROR: Program exceeds BRAM size." << std::endl;
        exit(1);
    }

#define STDOUT_BUF 1024
    char *stdoutBuf = new char[STDOUT_BUF]();

    // Wrap the program buffer into local memory object
    auto program_buffer_in = makeLocal(makeInOnly(
            makeWrappedPointer(program_buffer.data(), program_buffer.size())
    ));

    uint64_t fpga_sum = -1;
    RetVal<uint64_t> retval(&fpga_sum);

    int a = 42;
    int b = 1337;

    auto job = tapasco.launch(
        peID,                                                  // Processing Element ID
        retval,                                                // return value
        program_buffer_in,                                     // Program is passed as Arg 0
        a,                                                     // Arg 1
        b,                                                     // Arg 2
        makeOutOnly(makeWrappedPointer(stdoutBuf, STDOUT_BUF)) // Arg 3
    );

    cout << "Waiting for RISC-V " << endl;
    job();
    cout << "RISC-V return value: " << (fpga_sum & 0x0FFFFFFFF) << endl;

    uint32_t firstProgBytes = fpga_sum >> 32;

    cout << "First program bytes: " << hex << firstProgBytes << endl;

    cout << "RiscV STDOUT: " << stdoutBuf << endl;

    delete[] stdoutBuf;

    return 0;
}
