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

set(SOURCE_FILES ${SRC_FILES} ${RAGEL_FILES})

add_executable(blang ${SRC_FILES} ${RagelOutput})
