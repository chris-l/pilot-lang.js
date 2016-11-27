/*
 * PILOT parser
 * ==========================
 */

Begin
  = Instruction*

Instruction
  = R
  / T
  / A
  / M
  / JM
  / J
  / E
  / Label

Char
  = [a-zA-Z0-9] { return text(); }

_ "whitespace"
  = [ \t]*

nl "newlines"
  = [\n\r]*




Conditioner
  = ('Y' / 'N')

Expression
  = '(' content:[^)]* ')'
  {
    return content.join('');
  }

R
  = 'R' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Remark',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

T
  = 'T'? _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Type',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

A
  = 'A' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ variable:[^\n]* nl
  {
    var output = {
      instruction : 'Accept',
      conditioner : conditioner || false,
      expression : expression || false,
      variable : false
    };
    if (variable.length > 0) {
      output.variable = variable.join('');
    }
    return output;
  }
M
  = 'M' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ matches:[^\n]* nl
  {
     matches = matches.join('').split(/,\s*/);
     return {
       instruction : 'Match',
       conditioner : conditioner || false,
       expression : expression || false,
       matches : matches
     };
   }
commas
  = _ ',' _

JM
  = 'JM' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ labels:(Labl commas?)* nl
  {
     labels = labels.map(function (label) {
        return label[0];
     });
     return {
       instruction : 'JumpOnMatch',
       conditioner : conditioner || false,
       expression : expression || false,
       labels : labels
     };
   }
J
  = 'J' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl nl
  {
    return {
      instruction : 'Jump',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
E
  = 'E' _ conditioner:Conditioner? _ expression:Expression? _ ':' _ nl
  {
    return {
      conditioner : conditioner || false,
      expression : expression || false,
      instruction : 'End'
    };
  }

Labl = '*' text:[^\n, \t]+
  { return text.join('').toLowerCase(); }

Label
  = text:Labl nl
  { return {
      instruction : 'Label',
      label : text
    };
  }
