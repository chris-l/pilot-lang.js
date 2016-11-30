/*jslint node:true,indent:2*/
'use strict';

module.exports = function (self, arr) {
  return arr.reduce(function (str, part) {
    if (typeof part === 'string') {
      return str + part;
    }

    switch (part.element) {
    case 'string_ident':
      return str + self.identifiers.strings[part.value] || '';
    case 'numeric_ident':
      return str + self.identifiers.numeric[part.value] || '';
    case 'internal_ident':
      return str + self[part.value] || '';
    }
  }, '');
};
