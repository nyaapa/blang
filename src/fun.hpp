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

            void cgen() {
                std::cout << name << ":\n";
                std::cout << "\tpush rbp\n";
                std::cout << "\tmov rbp,rsp\n";

                for (auto& expr : exprs) 
                    expr->cgen();

                std::cout << "\tleave\n";
                std::cout << "\tret\n";
            }

            const std::string name;
            const std::list<std::shared_ptr<blang::expr>> exprs;
    };
}