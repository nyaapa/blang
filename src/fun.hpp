#pragma once

#include <string>
#include <list>
#include <memory>

#include "expr.hpp"

namespace blang {
    class fun {
        public:
            fun() {}
            fun(std::string name, std::list<std::shared_ptr<blang::expr>> exprs) : name{name}, exprs{exprs} {}

            const std::string name;
            const std::list<std::shared_ptr<blang::expr>> exprs;
    };
}