JQUERY = includes/jquery-1.11.3.min.js
STATE_MACHINE = state-machine.min.js

INCLUDES = $(JQUERY) $(STATE_MACHINE)


PROJECT_NAME = StateMachineBox
JS_FILES = js/StateMachineBox.coffee
TEST_FILES = test/...

make:
	cat $(JS_FILES) | coffee --compile --stdio > $(PROJECT_NAME).js
	sass css/smb.sass css/smb.css

test: make
	cat $(TEST_FILES) | coffee --compile --stdio > $(PROJECT_NAME).test.js

production: make
	uglifyjs $(PROJECT_NAME).js -o $(PROJECT_NAME).min.js -c -m drop_console=true -d DEBUG=false

production_inclusive: production
	cat $(INCLUDES) $(PROJECT_NAME).min.js > $(PROJECT_NAME).all.min.js
