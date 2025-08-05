#include <iostream>
#include "utils/helper.h"

int main() {
    std::cout << "OBD2 Tool - C++ Component" << std::endl;
    
    if (obd2::utils::Helper::initialize()) {
        std::cout << "Application initialized successfully" << std::endl;
    }
    
    return 0;
}