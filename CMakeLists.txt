cmake_minimum_required(VERSION 3.0.0)
project(Htmlex)

# Configuração do C++
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_STANDARD 11)
set(SRC_DIR src)

# Configuração do Flex
find_package(FLEX)
FLEX_TARGET(Lexer ${SRC_DIR}/lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.cc COMPILE_FLAGS "-+")
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_SOURCE_DIR})
#include_directories(${SRC_DIR})

# Executável depende também da saída do Flex
add_executable(${PROJECT_NAME} ${FLEX_Lexer_OUTPUTS})