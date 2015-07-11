JQUERY = js_includes/jquery-1.11.3.min.js
STATE_MACHINE = js_includes/state-machine.min.js

INCLUDES = $(JQUERY) $(STATE_MACHINE)

PROJECT_NAME = StateMachineBox

JS_FILES = js/StateMachineBox.coffee
TEST_FILES = test/StateMachineBox.coffee
# each file should be 1 theme
CSS_FILES = css/smb_default.sass

make:
	# compile coffee
	cat $(JS_FILES) | coffee --compile --stdio > $(PROJECT_NAME).js
	# compile sass
	cat $(CSS_FILES) > css/$(PROJECT_NAME).sass
	sass css/$(PROJECT_NAME).sass css/$(PROJECT_NAME).css

test: make
	cat $(TEST_FILES) | coffee --compile --stdio > $(PROJECT_NAME).test.js

production: make
	uglifyjs $(PROJECT_NAME).js -o $(PROJECT_NAME).min.js -c -m drop_console=true -d DEBUG=false

production_inclusive: production
	cat $(INCLUDES) $(PROJECT_NAME).min.js > $(PROJECT_NAME).all.min.js

clean:
	rm -f css/$(PROJECT_NAME).sass
	rm -f css/$(PROJECT_NAME).css
	rm -f $(PROJECT_NAME).js
	rm -f $(PROJECT_NAME).test.js
	rm -f $(PROJECT_NAME).min.js
	rm -f $(PROJECT_NAME).all.min.js
