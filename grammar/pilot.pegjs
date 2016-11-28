
/*
 * PILOT parser
 * ==========================
 */

Begin
  = Statement*

Statement
  = R
  / T
  / Y
  / N
  / A
  / M
  / JM
  / J
  / E
  / U
  / Label

Char
  = [a-zA-Z0-9] { return text(); }

_ "whitespace"
  = [ \t]*

nl "newlines"
  = [\n\r]*




Conditioner
  = [YyNn]
  {
    return text().toUpperCase();
  }

Expression
  = '(' content:[^)]* ')'
  {
    return content.join('');
  }

AthruZ
  = [a-zA-Z]

LimitedChar
  = [a-zA-Z0-9_]

LimitedString
  = LimitedChar{1,10}

StringIdent
  = ( '$' str:(AthruZ LimitedString)
  / str:(AthruZ LimitedString) '$' )
  {
    return (str[0] + str[1].join('')).toLowerCase();
  }

NumericIdent
  = '#' str:(AthruZ LimitedString)
  {
    return (str[0] + str[1].join('')).toLowerCase();
  }

R
  = ('Remark'i / 'R'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Remark',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

Y
  = ('Yes'i / 'Y'i) _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Type',
      conditioner : 'Y',
      expression : expression || false,
      text : text.join('')
    }
  }

N
  = ('No'i / 'N'i) _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Type',
      conditioner : 'N',
      expression : expression || false,
      text : text.join('')
    }
  }

T
  = ('Type'i / 'T'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Type',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

A
  = ('Accept'i / 'A'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ variable:[^\n]* nl
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
  = ('Match'i / 'M'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ matches:[^\n]* nl
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
  = 'JM'i _ conditioner:Conditioner? _ expression:Expression? _ ':' _ labels:(Labl commas?)* nl
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
  = ('Jump'i / 'J'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl nl
  {
    return {
      instruction : 'Jump',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
E
  = ('End'i / 'E'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ nl
  {
    return {
      conditioner : conditioner || false,
      expression : expression || false,
      instruction : 'End'
    };
  }
U
  = ('Use'i / 'U'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl _ nl
  {
    return {
      instruction : 'Use',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
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
