// Generated by CoffeeScript 1.9.3
(function() {
  var DEBUG, SMB,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  DEBUG = true;


  /**
  * @class StateMachineBox
  *
  * @constructor
  * @param stateMachineConfig {Object}
  * @param headline {String}
  * @param options {Object}
  *
   */

  window.StateMachineBox = (function() {

    /**
    * This property defines what modes the StateMachineBox class can have.
    * @final
    * @static
    * @property MODES
    * @type Object
    *
     */
    var FADE_THROUGH;

    StateMachineBox.MODES = {
      SINGLE: "single",
      MANY: "many"
    };


    /**
    * This property defines the current mode of the StateMachineBox class.
    * @static
    * @property MODE
    * @type String
    * @default MODES.SINGLE
    *
     */

    StateMachineBox.MODE = StateMachineBox.MODES.SINGLE;


    /**
    * This property defines how fast fade-in and fade-out animations are.
    * @static
    * @property FADE_TIME
    * @type Number
    * @default 180
    *
     */

    StateMachineBox.FADE_TIME = 180;

    StateMachineBox.BUTTON_ACTIONS = {
      OK: "CLOSE",
      CANCEL: "CANCEL",
      NEXT: "NEXT",
      PREV: "PREV"
    };

    StateMachineBox.BUTTONS = {
      OK: "<div class=\"button ok locale\" data-langkey=\"ok\" />",
      CANCEL: "<div class=\"button cancel locale\" data-langkey=\"cancel\" />",
      NEXT: "<div class=\"button next locale\" data-langkey=\"next\" />",
      PREV: "<div class=\"button prev locale\" data-langkey=\"prev\" />"
    };

    StateMachineBox.ACTIONS = {
      CLOSE: function() {
        return this.close();
      },
      OK: function() {
        this.close(true);
        if (this.callbacks.onOk instanceof Function) {
          this.callbacks.onOk();
        }
        return this;
      },
      CANCEL: function() {
        this.close(true);
        if (this.callbacks.onCancel instanceof Function) {
          this.callbacks.onCancel();
        }
        return this;
      },
      CHANGE: function(targetState) {
        return this.change(targetState);
      },
      NEXT: function() {
        return this.next();
      },
      PREV: function() {
        return this.prev();
      }
    };

    StateMachineBox.BUTTON_COLORS = ["#222222", "#9FA39F", "#B9BCB9", "#D3D5D3"];


    /**
    * This property defines all themes.
    * @static
    * @property THEMES
    * @type Object
    *
     */

    StateMachineBox.THEMES = {
      DEFAULT: "smb-default"
    };


    /**
    * This property defines the current theme of the StateMachineBox class.
    * @static
    * @property _theme
    * @type String
    * @default THEMES.DEFAULT
    *
     */

    StateMachineBox._theme = StateMachineBox.THEMES.DEFAULT;

    FADE_THROUGH = function(color, bodyWrapper, body, fader, fromContent, toContent, event, from, to, callback) {
      var self;
      self = this;
      fader.css("display", "block").animate({
        "background-color": color
      }, 200, "swing", function() {
        return self.constructor.ANIMATIONS.NONE.call(self, bodyWrapper, body, fader, fromContent, toContent, event, from, to, function() {
          return fader.animate({
            "background-color": "transparent"
          }, 200, "swing", function() {
            fader.css("display", "none");
            if (typeof callback === "function") {
              callback();
            }
            return true;
          });
        });
      });
      return true;
    };

    FADE_THROUGH.COLOR = function(color) {
      return function(bodyWrapper, body, fader, fromContent, toContent, event, from, to, callback) {
        return FADE_THROUGH.call(this, color, bodyWrapper, body, fader, fromContent, toContent, event, from, to, callback);
      };
    };

    FADE_THROUGH.WHITE = FADE_THROUGH.COLOR("#ffffff");

    FADE_THROUGH.BLACK = FADE_THROUGH.COLOR("#000000");

    FADE_THROUGH.THEME = function(bodyWrapper, body, fader, fromContent, toContent, event, from, to, callback) {
      var self;
      self = this;
      fader.css({
        display: "block",
        opacity: 0
      }).animate({
        opacity: 1
      }, 200, "swing", function() {
        return self.constructor.ANIMATIONS.NONE.call(self, bodyWrapper, body, fader, fromContent, toContent, event, from, to, function() {
          return fader.animate({
            opacity: 0
          }, 200, "swing", function() {
            fader.css("display", "none");
            if (typeof callback === "function") {
              callback();
            }
            return true;
          });
        });
      });
      return true;
    };

    StateMachineBox.ANIMATIONS = {
      SLIDE: function(bodyWrapper, body, fader, fromContent, toContent, event, from, to, callback) {
        body.append(toContent);
        if (event === "back") {
          bodyWrapper.prepend(body).css("margin-left", "-" + this.bodyWidth + "px").animate({
            "margin-left": "0px"
          }, 400, "swing", function() {
            $(this).children().eq(1).detach();
            if (typeof callback === "function") {
              callback();
            }
            return true;
          });
        } else if (from !== "none") {
          bodyWrapper.append(body).animate({
            "margin-left": "-" + this.bodyWidth + "px"
          }, 400, "swing", function() {
            $(this).children().eq(0).detach();
            $(this).css("margin-left", "0px");
            if (typeof callback === "function") {
              callback();
            }
            return true;
          });
        }
        return true;
      },
      FADE: function(bodyWrapper, body, fader, fromContent, toContent, event, from, to, callback) {
        return true;
      },
      FADE_THROUGH: FADE_THROUGH,
      NONE: function(bodyWrapper, body, fader, fromContent, toContent, event, from, to, callback) {
        body.append(toContent);
        bodyWrapper.find(".body").replaceWith(body);
        if (typeof callback === "function") {
          callback();
        }
        return true;
      }
    };

    StateMachineBox.ANIMATIONS.DEFAULT = StateMachineBox.ANIMATIONS.SLIDE;

    StateMachineBox._popups = [];

    StateMachineBox._activePopup = null;

    if (DEBUG) {
      StateMachineBox._localeKeys = ["ok", "cancel", "next", "prev"];
      StateMachineBox._languageKeys = ["aa", "ab", "ae", "af", "ak", "am", "an", "ar", "as", "av", "ay", "az", "ba", "be", "bg", "bh", "bi", "bm", "bn", "bo", "br", "bs", "ca", "ce", "ch", "co", "cr", "cs", "cu", "cv", "cy", "da", "de", "dv", "dz", "ee", "el", "en", "eo", "es", "et", "eu", "fa", "ff", "fi", "fj", "fo", "fr", "fy", "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi", "ho", "hr", "ht", "hu", "hy", "hz", "ia", "id", "ie", "ig", "ii", "ik", "io", "is", "it", "iu", "ja", "jv", "ka", "kg", "ki", "kj", "kk", "kl", "km", "kn", "ko", "kr", "ks", "ku", "kv", "kw", "ky", "la", "lb", "lg", "li", "ln", "lo", "lt", "lu", "lv", "mg", "mh", "mi", "mk", "ml", "mn", "mr", "ms", "mt", "my", "na", "nb", "nd", "ne", "ng", "nl", "nn", "no", "nr", "nv", "ny", "oc", "oj", "om", "or", "os", "pa", "pi", "pl", "ps", "pt", "qu", "rm", "rn", "ro", "ru", "rw", "sa", "sc", "sd", "se", "sg", "si", "sk", "sl", "sm", "sn", "so", "sq", "sr", "ss", "st", "su", "sv", "sw", "ta", "te", "tg", "th", "ti", "tk", "tl", "tn", "to", "tr", "ts", "tt", "tw", "ty", "ug", "uk", "ur", "uz", "ve", "vi", "vo", "wa", "wo", "xh", "yi", "yo", "za", "zh", "zu", "en-gb", "en-us", "en-ca", "en-au"];
    }

    StateMachineBox._$cache = {
      popup: $("<div class=\"smb\">\n    <div class=\"positioner\">\n        <div class=\"content\">\n            <div class=\"loader\" />\n            <div class=\"header\">\n                <div class=\"headline smb_noselect\" />\n            </div>\n            <div class=\"bodyWrapper\" />\n            <div class=\"fader\" />\n            <div class=\"navigation\" />\n            <div class=\"footer\" />\n        </div>\n        <div class=\"close\" />\n    </div>\n</div>"),
      overlay: $("<div class=\"smb-overlay\" />"),
      buttons: {
        raw: $("<div class=\"button raw\" />"),
        ok: $("<div class=\"button ok\" data-langkey=\"ok\" />"),
        cancel: $("<div class=\"button cancel\" data-langkey=\"cancel\" />"),
        next: $("<div class=\"button next\" data-langkey=\"next\" />"),
        prev: $("<div class=\"button prev\" data-langkey=\"prev\" />")
      }
    };

    StateMachineBox.locale = {};


    /**
    * This method initializes the StateMachineBox class. For example the default locales are set.
    * @static
    * @public
    * @method init
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.init = function() {
      this.setLocale("en", {
        ok: "ok",
        cancel: "cancel",
        next: "next",
        prev: "previous"
      });
      this.setLocale("de", {
        ok: "ok",
        cancel: "abbrechen",
        next: "weiter",
        prev: "zurück"
      });
      return this;
    };


    /**
    * This method finds out which StateMachineBox instance is the front most.
    * It doesn't work if custom styles or css classes are set.
    * @static
    * @public
    * @method getTopMost
    * @return {StateMachineBox}
    *
     */

    StateMachineBox.getTopMost = function() {
      var divs, j, len, popup, popups;
      popups = this._popups;
      divs = $();
      for (j = 0, len = popups.length; j < len; j++) {
        popup = popups[j];
        divs = divs.add(popup.div);
      }
      return popups[divs.index(divs.filter(":visible:last"))] || null;
    };


    /**
    * This method finds out which StateMachineBox instance is the front most.
    * It doesn't work if custom styles or css classes are set.
    * @static
    * @protected
    * @method getTopMost
    * @param popup {StateMachineBox}
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox._setActive = function(popup) {
      this._activePopup = popup;
      return this;
    };


    /**
    * This method returns the active StateMachineBox instance or the front most (if none are active).
    * @static
    * @protected
    * @method getActive
    * @return {StateMachineBox}
    *
     */

    StateMachineBox.getActive = function() {
      return this._activePopup || this.getTopMost();
    };


    /**
    * This method sets the locale information for a specific language. This information will be updated in all StateMachineBox'es by default.
    * @static
    * @protected
    * @method setLocale
    * @param language {String}
    * @param values {Object}
    * This object should have a key for each element in StateMachineBox._localeKeys. Errors depend on debug mode.
    * @param redraw {Boolean}
    * Optional. Default is true. If not true no instance of StateMachineBox will be updated.
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.setLocale = function(language, values, redraw) {
      var j, k, key, l, len, len1, len2, popup, ref, ref1, ref2;
      if (redraw == null) {
        redraw = true;
      }
      if (DEBUG) {
        if (indexOf.call(this._languageKeys, language) >= 0) {
          ref = this._localeKeys;
          for (j = 0, len = ref.length; j < len; j++) {
            key = ref[j];
            if (values[key] == null) {
              throw new Error("StateMachineBox.setLocale: Missing at least 1 key '" + key + "' for locale settings!");
            }
          }
          this.locale[language] = values;
          if (redraw === true) {
            ref1 = this._popups;
            for (k = 0, len1 = ref1.length; k < len1; k++) {
              popup = ref1[k];
              popup.redraw();
            }
          }
          return this;
        }
        throw new Error("StateMachineBox.setLocale: Invalid language '" + language + "' given!");
      }
      this.locale[language] = values;
      if (redraw === true) {
        ref2 = this._popups;
        for (l = 0, len2 = ref2.length; l < len2; l++) {
          popup = ref2[l];
          popup.redraw();
        }
      }
      return this;
    };


    /**
    * This method gets the locale value for a given language and and a given key. If no key is specified this method returns the data object for the given language.
    * @static
    * @protected
    * @method getLocale
    * @param language {String}
    * @param key {String}
    * Optional. Default resolves to all data. If given should match a key in StateMachineBox._languageKeys.
    * @return {String}
    *
     */

    StateMachineBox.getLocale = function(language, key) {
      var ref;
      if (DEBUG) {
        if (((ref = this.locale[language]) != null ? ref[key] : void 0) != null) {
          return this.locale[language][key];
        }
        if ((key == null) && (this.locale[language] != null)) {
          console.info("StateMachineBox.getLocale: No key given. Returning all keys for '" + language + "'.");
          return this.locale[language];
        }
        throw new Error("StateMachineBox.getLocale: language '" + language + "' not set or key '" + key + "' not found!");
      }
      if (key != null) {
        return this.locale[language][key] || null;
      }
      return this.locale[language];
    };


    /**
    * This method can be used to remove unneeded locale data from the memory.
    * @static
    * @method deleteLocale
    * @param language {String}
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.deleteLocale = function(language) {
      if (DEBUG) {
        if (this.locale[language] != null) {
          delete this.locale[language];
        } else {
          console.warn("StateMachineBox.deleteLocale: language '" + language + "' not set thus can't be deleted!");
        }
        return this;
      }
      delete this.locale[language];
      return this;
    };

    StateMachineBox.addTheme = function(theme) {
      if (DEBUG) {
        if (this.THEMES[theme] == null) {
          if (theme !== theme.toUpperCase()) {
            console.warn("StateMachineBox.addTheme: For consistency it is recommended to use upper case theme names. Theme '" + theme + "' will be set anyways.");
          }
          this.THEMES[theme] = theme;
        }
        throw new Error("StateMachineBox.addTheme: Theme '" + theme + "' already exists!");
      }
      this.THEMES[theme] = theme;
      return this;
    };

    StateMachineBox.setTheme = function(theme, redraw) {
      var j, k, len, len1, popup, ref, ref1;
      if (redraw == null) {
        redraw = true;
      }
      if (DEBUG) {
        if (this.THEMES[theme] != null) {
          this._theme = this.THEMES[theme];
          if (redraw === true) {
            ref = this._popups;
            for (j = 0, len = ref.length; j < len; j++) {
              popup = ref[j];
              popup.setTheme(this._theme);
            }
          }
          return this;
        }
        throw new Error("StateMachineBox.setTheme: Invalid theme '" + theme + "' given!");
      }
      this._theme = this.THEMES[theme];
      if (redraw === true) {
        ref1 = this._popups;
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          popup = ref1[k];
          popup.setTheme(this._theme);
        }
      }
      return this;
    };


    /**
    * This method can be used to add a StateMachineBox to the list of registered instances.
    * @static
    * @protected
    * @method _registerPopup
    * @param popup {StateMachineBox}
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox._registerPopup = function(popup) {
      if (indexOf.call(this._popups, popup) < 0) {
        this._popups.push(popup);
      }
      return this;
    };


    /**
    * This method can be used to remove a StateMachineBox from the list of registered instances.
    * @static
    * @protected
    * @method _unregisterPopup
    * @param popup {StateMachineBox}
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox._unregisterPopup = function(popup) {
      var i, p;
      this._popups = (function() {
        var j, len, ref, results;
        ref = this._popups;
        results = [];
        for (i = j = 0, len = ref.length; j < len; i = ++j) {
          p = ref[i];
          if (p !== popup) {
            results.push(p);
          }
        }
        return results;
      }).call(this);
      return this;
    };

    StateMachineBox["new"] = function(stateMachineConfig, headline, options) {
      if (options == null) {
        options = {};
      }
      return new this(stateMachineConfig, headline, options);
    };

    function StateMachineBox(stateMachineConfig, headline, options) {
      var CLASS, callback, callbackName, css, event, height, j, k, len, len1, ref, ref1, ref2, self, width;
      if (options == null) {
        options = {};
      }
      if (DEBUG) {
        if ((stateMachineConfig == null) || (stateMachineConfig.events == null)) {
          throw new Error("StateMachineBox::constructor: No (valid) state machine configuration given!");
        }
        ref = stateMachineConfig.events;
        for (j = 0, len = ref.length; j < len; j++) {
          event = ref[j];
          if (this[event.name] != null) {
            throw new Error("StateMachineBox::constructor: Trying to create event '" + event.name + "' but that property already exists in popup!!");
          }
        }
        ref1 = stateMachineConfig.callbacks;
        for (callbackName in ref1) {
          callback = ref1[callbackName];
          if (this[callbackName] != null) {
            throw new Error("StateMachineBox::constructor: Trying to create callback '" + callbackName + "' but that property already exists in popup!!");
          }
        }
      }
      CLASS = this.constructor;
      this.headline = headline;
      this.options = options;
      this.closeButtonAction = options.closeButtonAction || "close";
      this.callbacks = options.callbacks || {};
      this.theme = options.theme || CLASS.THEMES.DEFAULT;
      this.locale = options.locale || "en";
      this.showNavigation = options.showNavigation || false;
      this.container = options.container || $(document.body);
      this._animate = options.animation || CLASS.ANIMATIONS.DEFAULT;
      this.data = {
        eventPath: []
      };
      this._drawn = false;
      this.div = CLASS._$cache.popup.clone().addClass(this.theme);
      this.overlay = CLASS._$cache.overlay.clone().addClass(this.theme);
      this.bodyWrapper = this.div.find(".bodyWrapper");
      this.fader = this.div.find(".fader");
      this.navigation = this.div.find(".navigation");
      this.loader = this.div.find(".loader");
      this.footer = this.div.find(".footer");
      css = {};
      if (((width = options.width) != null) && ((height = options.height) != null)) {
        width = parseInt(width, 10);
        height = parseInt(height, 10);
        if (isNaN(width)) {
          css.width = "auto";
        } else {
          css.width = width + "px";
        }
        if (isNaN(height)) {
          css.height = "auto";
        } else {
          css.height = height + "px";
        }
      }
      if (!options.left) {
        if ((css.width != null) && css.width !== "auto") {
          css.left = "calc(50% - " + (width / 2) + "px)";
        }
      }
      if (!options.top) {
        if ((css.height != null) && css.height !== "auto") {
          css.top = "calc(50% - " + (height / 2) + "px)";
        }
      }
      this.div.css(css);
      this.bodyWidth = parseFloat(this.options.width) || 800;
      this.bodyPadding = {
        top: 10,
        right: 40,
        bottom: 10,
        left: 40
      };
      this._active = false;
      stateMachineConfig.target = this;
      this.stateMachineConfig = stateMachineConfig;
      this.contents = {};
      ref2 = stateMachineConfig.events;
      for (k = 0, len1 = ref2.length; k < len1; k++) {
        event = ref2[k];
        if (event.content != null) {
          this.contents[event.to] = event.content;
        }
      }
      self = this;
      if (stateMachineConfig.callbacks == null) {
        stateMachineConfig.callbacks = {};
      }
      stateMachineConfig.callbacks.onenterstate = function() {
        var event, from, params, to;
        event = arguments[0], from = arguments[1], to = arguments[2], params = 4 <= arguments.length ? slice.call(arguments, 3) : [];
        console.log("onenterstate", arguments);
        if (self.beforeChange instanceof Function && self.beforeChange(to) === false) {
          return false;
        }
        self._changeContent(event, from, to);
        self.data.eventPath.push(event);
        if (typeof self.onChange === "function") {
          self.onChange(event, from, to);
        }
        return true;
      };
      StateMachine.create(stateMachineConfig);
      CLASS._registerPopup(this);
    }


    /**
    * This method sets the current StateMachineBox instance as currently active.
    * @protected
    * @method _setAsActive
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype._setAsActive = function() {
      this.constructor._setActive(this);
      return this;
    };


    /**
    * This method show the instance's div.
    * @method show
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.show = function(callback) {
      this.div.fadeIn(this.constructor.FADE_TIME, callback);
      return this;
    };


    /**
    * This method hides the instance's div.
    * @method hide
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.hide = function(callback) {
      this.div.fadeOut(this.constructor.FADE_TIME, callback);
      return this;
    };


    /**
    * This method shows the instance's overlay.
    * @method showOverlay
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.showOverlay = function(callback) {
      this.overlay.fadeIn(this.constructor.FADE_TIME, callback);
      return this;
    };


    /**
    * This method hides the instance's overlay.
    * @method hideOverlay
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.hideOverlay = function(callback) {
      this.overlay.fadeOut(this.constructor.FADE_TIME, callback);
      return this;
    };


    /**
    * This method shows the instance's ajax loader.
    * @method showLoader
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.showLoader = function() {
      this.loader.fadeIn(this.constructor.FADE_TIME);
      return this;
    };


    /**
    * This method hides the instance's ajax loader.
    * @method hideLoader
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.hideLoader = function() {
      this.loader.fadeOut(this.constructor.FADE_TIME);
      return this;
    };


    /**
    * This method triggers an action (one of StateMachineBox.ACTIONS).
    * Those actions are a subset of all events.
    * @method fireAction
    * @param name {string}
    * The name of the action.
    * @param params... {mixed}
    * Optional. Any parameter will be passed to the action.
    * @return {mixed}
    *
     */

    StateMachineBox.prototype.fireAction = function() {
      var action, name, params;
      name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      name = name.toUpperCase();
      if ((action = this.constructor.ACTIONS[name]) != null) {
        return action.apply(this, params);
      }
      if (DEBUG) {
        throw new Error("Popup::fireAction: No action with name '" + name + "' found!");
      }
      return null;
    };


    /**
    * This method hides the instance's ajax loader.
    * @method close
    * @param ignoreCallback {Boolean}
    * Optional. Default is false. Indicates if the beforeClose and onClose callbacks will be called.
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.close = function(ignoreCallback) {
      var base, self;
      if (ignoreCallback == null) {
        ignoreCallback = false;
      }
      if (!ignoreCallback && this.beforeClose instanceof Function && this.beforeClose() === false) {
        return false;
      }
      self = this;
      this.hide(function() {
        self.div.remove();
        return true;
      });
      this.hideOverlay(function() {
        self.overlay.remove();
        return true;
      });
      this.constructor._unregisterPopup(this);
      if (!ignoreCallback) {
        if (typeof (base = this.callbacks).onClose === "function") {
          base.onClose();
        }
      }
      return this;
    };


    /**
    * Synonym for close.
    * @method remove
    *
     */

    StateMachineBox.prototype.remove = function() {
      return this.close.apply(this, arguments);
    };


    /**
    * This method hides the instance's ajax loader.
    * @protected
    * @method _changeContent
    * @param event {String}
    * The name of the event which causes the content to change.
    * @param from {String}
    * The name of the state that we're coming from.
    * @param to {String}
    * The name of the state that we're going to.
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype._changeContent = function(event, from, to) {
      var body, content;
      content = this.contents[to];
      if (content == null) {
        if (DEBUG) {
          throw new Error("StateMachineBox::_changeContent: No content given for '" + to + "'!");
        }
        return this;
      }
      body = $("<div class=\"body\" style=\"width: " + (this.bodyWidth - this.bodyPadding.left - this.bodyPadding.right) + "px;\" />");
      this._animate(this.bodyWrapper, body, this.fader, this.contents[this.current], content, event, from, to, this.callbacks.onAnimate);
      return this;
    };


    /**
    * This method returns the content associated with the current state.
    * @method currentContent
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.currentContent = function() {
      return this.contents[this.current];
    };

    StateMachineBox.prototype.getLocale = function(key) {
      return this.constructor.getLocale(this.locale, key);
    };


    /**
    * This method draws the StateMachineBox instance to the DOM.
    * @method draw
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.draw = function() {
      var action, b, body, button, buttons, content, event, eventName, idx, j, lastColor, len, self;
      if (this.constructor.MODE === this.constructor.MODES.SINGLE && (this.constructor.getActive() != null)) {
        console.warn("Popup::draw: tried to draw more than 1 popup but mode is set to 'single'!");
        return this;
      }
      if (this._drawn === true) {
        console.warn("Popup::draw: tried to draw same StateMachineBox instance more than once!");
        return this;
      }
      self = this;
      this.div.find(".headline").append(this.headline);
      this.div.find(".overlay, .close").click(function() {
        self.fireAction(self.closeButtonAction);
        return true;
      });
      this.div.mousedown(function() {
        self._setAsActive();
        return true;
      });
      buttons = this.options.buttons || [];
      for (idx = j = 0, len = buttons.length; j < len; idx = ++j) {
        button = buttons[idx];
        if (!(button != null)) {
          continue;
        }
        action = null;
        if (typeof button === "string") {
          b = button.toLowerCase();
          button = this.constructor._$cache.buttons[b].clone();
          event = this.constructor.ACTIONS[this.constructor.BUTTON_ACTIONS[b]];
          eventName = b;
        } else if ((button.button != null) && (button.action != null)) {
          b = button;
          button = this.constructor._$cache.buttons[b.button.toLowerCase()].clone();
          event = this.constructor.ACTIONS[b.action.toLowerCase()];
          eventName = b.action.toLowerCase();
        } else if ((button.event != null) && (button.label != null)) {
          if (DEBUG) {
            if (this[button.event] == null) {
              console.warn("StateMachineBox::draw: Invalid button configuration for StateMachineBox! Invalid button event '" + eventName + "'!", this.options.buttons);
              continue;
            }
          }
          b = button;
          button = this.constructor._$cache.buttons.raw.clone();
          if (b.locale === true) {
            button.text(this.getLocale(b.label));
          } else {
            button.text(b.label);
          }
          event = this[b.event];
          eventName = b.event;
        } else if (DEBUG) {
          button = null;
        }
        if (DEBUG) {
          if (button == null) {
            console.warn("StateMachineBox::draw: Invalid button configuration for StateMachineBox!", this.options.buttons);
            continue;
          }
        }
        if (event != null) {
          lastColor = this.constructor.BUTTON_COLORS[idx];
          button.css({
            "background-color": lastColor
          });
          (function(eventName) {
            return button.click(function() {
              self.fireEvent(eventName);
              return true;
            });
          })(eventName);
          this.footer.append(button);
        }
      }
      this.footer.css("background-color", lastColor);
      self = this;
      if (!this.showNavigation) {
        this.navigation.addClass("hidden");
      }
      this.init();
      content = this.contents[this.current];
      if (content == null) {
        throw new Error("StateMachineBox::draw: No content found for '" + this.current + "'!");
      }
      body = $("<div class=\"body\" style=\"width: " + (this.bodyWidth - this.bodyPadding.left - this.bodyPadding.right) + "px;\" />");
      body.append(content);
      this.bodyWrapper.append(body);
      if (this.constructor.MODE === this.constructor.MODES.MANY) {
        this.div.draggable({
          handle: ".header"
        }).addClass("draggable");
      } else if (this.constructor.MODE === this.constructor.MODES.SINGLE) {
        this.container.append(this.overlay.click(function() {
          console.log("asdfasdfasdf");
          self.fireAction("cancel");
          return true;
        }));
      }
      this.container.append(this.div);
      this._setAsActive();
      return this;
    };


    /**
    * This method redraws the StateMachineBox instance.
    * This does not actually redraw everything but resets the texts of elements containing locale data.
    * @method redraw
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.redraw = function() {
      var elems, key, ref, val;
      elems = this.div.find(".locale");
      ref = this.contructor.getLocale(this.locale);
      for (key in ref) {
        val = ref[key];
        elems.filter("[data-langkey=\"" + key + "\"]").text(val);
      }
      return this;
    };


    /**
    * This method redraws the StateMachineBox instance.
    * This does not actually redraw everything but resets the theme css classes of the according elements.
    * @method redraw
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.setTheme = function(theme) {
      if (this.theme !== theme) {
        this.div.find("." + this.theme).removeClass(this.theme).addClass(theme);
      }
      return this;
    };


    /**
    * This method triggers an event. If the event is invalid for the current state onFailure will be called.
    * This method might seem a bit unnecessary but implicit event function calls might appear weird and this method has better error reporting.
    * @method fireEvent
    * @param name {String}
    * The name of the event to trigger.
    * @param params... {mixed}
    * Optional. Any parameter will be passed to the event callback.
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.fireEvent = function() {
      var base, e, name, params;
      name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (this[name] instanceof Function) {
        if (DEBUG) {
          try {
            this[name].apply(this, params);
          } catch (_error) {
            e = _error;
            console.warn("StateStatePopup::fireEvent: Event '" + name + "' is invalid for current state!");
            throw e;
          } finally {
            return this;
          }
        }
        this[name].apply(this, params);
        return this;
      }
      console.warn("StateStatePopup::fireEvent: There is no event called '" + name + "'! Use onFailure() to catch that!");
      if (typeof (base = this.callbacks).onFailure === "function") {
        base.onFailure(name);
      }
      return this;
    };


    /**
    * This method is a convenience method for fireEvent. If the state allows only 1 event this method will trigger that event.
    * @method next
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.next = function() {
      var base, base1, event, foundEvents, j, len, ref;
      if (this.beforeNext instanceof Function && this.beforeNext() === false) {
        return this;
      }
      foundEvents = [];
      ref = this.stateMachineConfig.events;
      for (j = 0, len = ref.length; j < len; j++) {
        event = ref[j];
        if (event.from === this.current && event.name !== "back") {
          foundEvents.push(event);
        }
      }
      if (foundEvents.length === 1) {
        this.fireEvent(foundEvents.first.name);
        return this;
      }
      if (foundEvents.length === 0) {
        console.warn("StateMachineBox::next: There is no event for '" + this.current + "'! Can't go any further! Use onFailure() to catch that!");
        if (typeof (base = this.callbacks).onFailure === "function") {
          base.onFailure("next");
        }
        return this;
      }
      console.warn("StateMachineBox::next: More than 1 event for '" + this.current + "': [" + ((function() {
        var k, len1, results;
        results = [];
        for (k = 0, len1 = foundEvents.length; k < len1; k++) {
          event = foundEvents[k];
          results.push(event.name);
        }
        return results;
      })()) + "]! Can't decide where to go! Use onFailure() to catch that!");
      if (typeof (base1 = this.callbacks).onFailure === "function") {
        base1.onFailure("next");
      }
      return this;
    };


    /**
    * This method is a convenience method for fireEvent (just like next). The difference here is that the state machine has no direction so next and prev are indistinguishable. Therefore the state machine must have a 'back' event for all states that are supposed to allow prev.
    * Only if there is exactly 1 other state that has an event that changes to the current state, prev can be applied.
    * @method prev
    * @return {StateMachineBox}
    * @chainable
    *
     */

    StateMachineBox.prototype.prev = function() {
      var base, e;
      if (this.beforePrev instanceof Function && this.beforePrev() === false) {
        return this;
      }
      try {
        this.back();
        return this;
      } catch (_error) {
        e = _error;
        console.warn("StateMachineBox::prev: Cannot go to 'prev' because no back route was defined! Define it with '{ name: 'back', from: 'prevState', to: 'returnState' }' ;) Use onFailure() to catch that!");
        console.warn(e);
        if (typeof (base = this.callbacks).onFailure === "function") {
          base.onFailure("prev");
        }
        return this;
      }
    };

    return StateMachineBox;

  })();

  StateMachineBox.init();

  SMB = (function(superClass) {
    extend(SMB, superClass);

    function SMB() {
      return SMB.__super__.constructor.apply(this, arguments);
    }

    return SMB;

  })(StateMachineBox);

}).call(this);
