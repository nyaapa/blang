cmake_minimum_required(VERSION 2.8)

file(
    GLOB_RECURSE
    SRC_FILES
    *.cpp
)

file(
    GLOB_RECURSE
    RAGEL_FILES
    lexer.rl
)

FIND_PROGRAM(RAGEL_EXECUTABLE ragel)
set(RagelOutput lexer.cpp)
add_custom_command(
	OUTPUT ${RagelOutput}
	COMMAND ${RAGEL_EXECUTABLE}
		-C -o ${RagelOutput}
		${RAGEL_FILES}
	DEPENDS ${RAGEL_FILES}
	COMMENT "Generating lexer.cpp"
)

file(
    GLOB_RECURSE
    BISON_FILES
    parser.yy
)

find_package(BISON REQUIRED)
set(BisonOutput parser.cc)
add_custom_command(
	OUTPUT ${BisonOutput}
	COMMAND ${BISON_EXECUTABLE}
		-o ${BisonOutput}
		${BISON_FILES}
	DEPENDS ${BISON_FILES}
	COMMENT "Generating parser.cc"
)

set(SOURCE_FILES ${SRC_FILES} ${RAGEL_FILES} ${BISON_FILES})

add_executable(blangc ${SRC_FILES} ${RagelOutput} ${BisonOutput})
