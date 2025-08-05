#pragma once

#include <string>

namespace obd2 {
namespace utils {

/**
 * @brief Utility functions for OBD2 tool
 */
class Helper {
public:
    /**
     * @brief Get version string
     * @return Version string
     */
    static std::string getVersion();
    
    /**
     * @brief Initialize the application
     * @return true if successful, false otherwise
     */
    static bool initialize();
};

} // namespace utils
} // namespace obd2