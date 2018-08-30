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

    class intc : public expr {
        public:
            intc(int val) : val{val} {}

            virtual void cgen() {
                std::cout << "\tmov rax, " << val << "\n";
            }

            const int val;
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
                    for (int i = 0; i < 8; ++i) {
                        value <<= 8;
                        if (it != arg->val.rend()) {
                            value |= static_cast<unsigned char>(*it);
                            ++it;
                        }
                    }
                    std::cout << "\tmov rax, " << value << "\n";
                    std::cout << "\tpush qword rax\n";
                }
                std::cout << "\tmov rax, 1\n";
                std::cout << "\tmov rsi, rsp\n";
                uint qwords = (arg->val.length() + 7) / 8 * 8;
                std::cout << "\tmov rdx, " << qwords << "\n";
                std::cout << "\tsyscall\n";
                std::cout << "\tadd rsp, " << qwords << "\n";
            }

            const std::string fname;
            const std::shared_ptr<expr> arg;
    };

    class sum : public expr {
        public:
            sum(std::shared_ptr<expr> left, std::shared_ptr<expr> right) : left{left}, right{right} {}

            void cgen() override {
                left->cgen();
                std::cout << "\tpush qword rax\n";
                right->cgen();
                std::cout << "\tpop qword rbx\n";
                std::cout << "\tadd rax, rbx\n";
            }

            const std::shared_ptr<expr> left;
            const std::shared_ptr<expr> right;
    };
}