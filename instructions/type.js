/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  var text, self = this;

  text = instruction.text.reduce(function (str, part) {
    if (typeof part === 'string') {
      str += part;
    }
    if (part.element === 'string_ident') {
      str += self.identifiers.strings[part.value] || '';
    }
    return str;
  }, '');

  self.output(text);
};
