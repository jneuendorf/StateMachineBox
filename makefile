JQUERY = js_includes/jquery-1.11.3.min.js
JQUERY_UI = js_includes/jquery-ui-1.11.2.min.js
STATE_MACHINE = js_includes/state-machine.min.js

INCLUDES = $(JQUERY) $(JQUERY_UI) $(STATE_MACHINE)

PROJECT_NAME = StateMachineBox

COFFEE_FILES = js/StateMachineBox.coffee js/SMB.coffee
DEBUG_FILE = js/debug.coffee
TEST_FILES = test/StateMachineBox.coffee
# each file should be 1 theme
CSS_FILES = css/general.sass css/smb_default.sass

# debugging mode
make:
	# compile coffee
	cat $(DEBUG_FILE) $(COFFEE_FILES) | coffee --compile --stdio > $(PROJECT_NAME).js
	# compile sass
	cat $(CSS_FILES) > css/$(PROJECT_NAME).sass
	sass css/$(PROJECT_NAME).sass css/$(PROJECT_NAME).css

# production mode
_make_no_debug:
	# compile coffee
	cat $(COFFEE_FILES) | coffee --compile --stdio > $(PROJECT_NAME).prod.js
	# compile sass
	cat $(CSS_FILES) > css/$(PROJECT_NAME).sass
	sass css/$(PROJECT_NAME).sass css/$(PROJECT_NAME).css

test: make
	cat $(TEST_FILES) | coffee --compile --stdio > $(PROJECT_NAME).test.js

doc: make
	yuidoc .

production: _make_no_debug
	uglifyjs $(PROJECT_NAME).prod.js -o $(PROJECT_NAME).min.js -c -m drop_console=true -d DEBUG=false
	rm -f $(PROJECT_NAME).prod.js
	java -jar yuicompressor-2.4.8.jar css/$(PROJECT_NAME).css -o css/$(PROJECT_NAME).min.css --charset utf-8

production_inclusive: production
	cat $(INCLUDES) $(PROJECT_NAME).min.js > $(PROJECT_NAME).all.min.js

clean:
	rm -f css/$(PROJECT_NAME).sass
	rm -f css/$(PROJECT_NAME).css
	rm -f $(PROJECT_NAME).js
	rm -f $(PROJECT_NAME).test.js
	rm -f $(PROJECT_NAME).min.js
	rm -f $(PROJECT_NAME).all.min.js
