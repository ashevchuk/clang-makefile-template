#pragma once

#include <iostream>

const int _exp = 7;

constexpr double square(double x) { return x * x; }

constexpr double simple1 = 3.1415 * square(_exp);

int test(void);