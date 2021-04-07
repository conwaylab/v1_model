/* MyMEXFunction

*/

#include "mex.hpp"
#include "mexAdapter.hpp"

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {

    void operator()(ArgumentList outputs, ArgumentList inputs) {
        //TypedArray<double> eccen = std::move(inputs[0]);
        //TypedArray<double> angle = std::move(inputs[1]);
        //TypedArray<double> sigma = std::move(inputs[2]);
        //TypedArray<double> orientation = std::move(inputs[3]);
        //TypedArray<double> orientation = std::move(inputs[3]);
        TypedArray<double> arr1 = std::move(inputs[0]);
        //TypedArray<double> arr2 = std::move(inputs[0])
        std::cout << arr1[1];
        //outputs[0] = arr1[0];
    }

    
};