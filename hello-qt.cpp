#include <iostream>
#include <QDebug>

#include <CVCError.h>

#include <boost/container/flat_map.hpp>

int main() {
    std::cout << "Hello, World!" << std::endl;
    qDebug() << CVC_ERROR_CODES::CVC_E_OK;

    boost::container::flat_map<int, int> m;
    m.insert({1, 2});
    m.insert({3, 4});

    for (auto &p : m) {
        std::cout << p.first << " " << p.second << std::endl;
    }

    return 0;
}
