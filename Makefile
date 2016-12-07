program: lint parser dist

parser:
	node_modules/pegjs/bin/pegjs -o grammar/parser.js grammar/pilot.pegjs
lint:
	node_modules/jslint/bin/jslint.js --indent 2 --color package.json main.js demo/*.js instructions/*.js lib/*.js
dist: parser
	node_modules/browserify/bin/cmd.js -s pilotCreator main.js | node_modules/uglifyjs/bin/uglifyjs > dist/pilot.min.js
