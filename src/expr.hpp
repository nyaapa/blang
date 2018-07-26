#pragma once

#include <string>
#include <memory>
#include <iostream>

namespace blang {
    class expr {
        public:
            expr() {}
            expr(int val) : val{std::to_string(val)} {}

            expr(const std::string&& val) : val{val} {}
            expr(std::string val) : val{val} {}

            virtual void cgen() {}

            const std::string val;
    };

    class fcall : public expr {
        public:
            fcall(std::string fname, std::shared_ptr<expr> arg) : fname{fname}, arg{arg} {}

            void cgen() override {
                if (fname != "print") {
                    throw std::runtime_error("niy");
                }

                std::cout << "\tmov rdi, 1\n";
                for (auto it = arg->val.rbegin(); it != arg->val.rend();) {
                    ulong value = 0;
                    for (int i = 0; i < 4; ++i) {
                        value <<= 8;
                        if (it != arg->val.rend()) {
                            value |= static_cast<unsigned char>(*it);
                            ++it;
                        }
                    }
                    std::cout << "\tpush " << value << "\n";
                }
                std::cout << "\tmov rax, 1\n";
                std::cout << "\tmov rsi, rsp\n";
                std::cout << "\tmov rdx, " << arg->val.length() * 2 <<"\n";
                std::cout << "\tsyscall\n";
                std::cout << "\tadd rsp, " << arg->val.length() / 4 << "\n";
            }

            const std::string fname;
            const std::shared_ptr<expr> arg;
    };
}