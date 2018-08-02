#pragma once

#include <vector>
#include <memory>
#include <algorithm>

#include "fun.hpp"

namespace blang {
    class source {
        public:
            source() {}
            source(const source&) = delete;
            source(source&&) = delete;
            source& operator=(const source&) = delete;
            source& operator=(source&&) = delete;

            void add_fun(std::shared_ptr<fun> fun) {
                funs.emplace_back(std::move(fun));
            }

            void cgen() {
                // TODO: polymorph?
                bool has_main = false;
                for (auto& fun : funs) {
                    std::cout << "global " << fun->name << "\n";
                    has_main = has_main || fun->name == "main";
                }

                // add it as a function?
                if (has_main) {
                    std::cout << "global _start\n";
                    std::cout << "_start:\n";
                    std::cout << "\tcall main\n";
                    std::cout << "\tmov rax, 60\n";
                    std::cout << "\tmov rdi, 0\n";
                    std::cout << "\tsyscall\n";
                }

                for (auto& fun : funs)
                    fun->cgen();
            }

        private:
            // TODO: polymorphy?
            std::vector<std::shared_ptr<fun>> funs;
    };
}