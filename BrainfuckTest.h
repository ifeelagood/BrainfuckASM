#include <CppUnitTest.h>

// Declare the ASM function
extern "C" int add_numbers(int a, int b);

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace UnitTestASM
{
TEST_CLASS(UnitTestASM)
{
public:

    TEST_METHOD(TestAddNumbers)
    {
        // Arrange
        int a = 5;
        int b = 10;

        // Act
        int result = add_numbers(a, b);

        // Assert
        Assert::AreEqual(15, result);
    }
};
}