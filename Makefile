program: lint parser

parser:
	node_modules/pegjs/bin/pegjs -o lib/pilot.js grammar/pilot.pegjs
lint:
	node_modules/jslint/bin/jslint.js --indent 2 --color package.json main.js instructions/*.js lib/prepareText.js