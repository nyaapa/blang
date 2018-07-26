#pragma once

#include <string>

namespace blang {
    class expr {
        public:
            expr() {}
            expr(int val) : val{std::to_string(val)} {}

            expr(const std::string&& val) : val{val} {}
            expr(std::string val) : val{val} {}

            const std::string val;
    };
}