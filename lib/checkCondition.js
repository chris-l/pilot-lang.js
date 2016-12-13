/*jslint node:true,indent:2*/
'use strict';
var doMathFun = require('./math');

module.exports = function (self, condition) {
  var binary, convert, doMath = doMathFun(self);

  binary = function (ele) {
    switch (ele.operator) {
    case '=':
      return convert(ele.left) === convert(ele.right);
    case '<>':
      return convert(ele.left) !== convert(ele.right);
    case '<':
      return convert(ele.left) < convert(ele.right);
    case '>':
      return convert(ele.left) > convert(ele.right);
    case '<=':
      return convert(ele.left) <= convert(ele.right);
    case '>=':
      return convert(ele.left) >= convert(ele.right);
    }
  };

  convert = function (ele) {
    if (typeof ele === 'number') {
      return ele;
    }
    if (ele.type === 'relationalExpression') {
      return binary(ele);
    }
    if (ele.element === 'BinaryOperation') {
      return doMath(ele);
    }
    if (ele.element === 'numeric_ident') {
      return self.identifiers.numeric[ele.value] || 0;
    }
    if (ele.element === 'internal_ident') {
      return parseInt(self[ele.value], 10) || 0;
    }
  };

  if (condition.type === 'mathExpression') {
    if (condition.expression.element === 'numeric_ident') {
      return (self.identifiers.numeric[condition.expression.value] || 0) > 0;
    }
    return doMath(condition) > 0;
  }

  if (condition.type === 'relationalExpression') {
    return convert(condition);
  }
};
