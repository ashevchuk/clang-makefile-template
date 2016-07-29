#include "main.hpp"
#include <stdio.h>

int main(int argc, char* argv[], char** envp) {
    std::cout << _BUILD_REPO_VERSION_ << "\n";
    test();
}
