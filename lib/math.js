/*jslint node:true,indent:2*/
'use strict';

module.exports = function (self) {
  return function (value) {
    var binary, convert;

    binary = function (ele) {
      switch (ele.operator) {
      case '+':
        return convert(ele.left) + convert(ele.right);
      case '-':
        return convert(ele.left) - convert(ele.right);
      case '*':
        return convert(ele.left) * convert(ele.right);
      case '/':
        return convert(ele.left) / convert(ele.right);
      case '%':
        return convert(ele.left) % convert(ele.right);
      }
    };

    convert = function (ele) {
      if (typeof ele === 'number') {
        return ele;
      }
      if (ele.element === 'BinaryOperation') {
        return binary(ele);
      }
      if (ele.element === 'numeric_ident') {
        return self.identifiers.numeric[ele.value] || 0;
      }
      if (ele.element === 'internal_ident') {
        return self[ele.value] || 0;
      }
    };

    return convert(value);
  };
};

