/*jslint node:true,indent:2*/
'use strict';
var prepareText = require('../lib/prepareText');

module.exports = function (instruction) {
  var self = this, id, value, convert, binary;

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
      return self.identifiers.numeric[ele.value];
    }
  };




  id = instruction.assignment.identifier;
  value = instruction.assignment.value;

  if (id.element === 'string_ident') {
    value = prepareText(self, value);
    self.identifiers.strings[id.value] = value;
  }

  if (id.element === 'numeric_ident') {
    self.identifiers.numeric[id.value] = convert(value);
  }
};

