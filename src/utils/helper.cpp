#include "helper.h"
#include <iostream>

namespace obd2 {
namespace utils {

std::string Helper::getVersion() {
    return "1.3.0";
}

bool Helper::initialize() {
    std::cout << "Initializing OBD2 Tool C++ Component v" << getVersion() << std::endl;
    return true;
}

} // namespace utils
} // namespace obd2