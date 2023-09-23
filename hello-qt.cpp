#include <iostream>
#include <QDebug>

#include <CVCError.h>

int main() {
    std::cout << "Hello, World!" << std::endl;
    qDebug() << CVC_ERROR_CODES::CVC_E_OK;

    return 0;
}
