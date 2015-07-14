###*
* @class StateMachineBox
*
* @constructor
* @param stateMachineConfig {Object}
* @param headline {String}
* @param options {Object}
*###
class window.StateMachineBox

    ###*
    * This property defines what modes the StateMachineBox class can have.
    * @final
    * @static
    * @property MODES
    * @type Object
    *###
    @MODES =
        SINGLE: "single"
        MANY:   "many"
    ###*
    * This property defines the current mode of the StateMachineBox class.
    * @static
    * @property MODE
    * @type String
    * @default MODES.SINGLE
    *###
    @MODE = @MODES.SINGLE
    ###*
    * This property defines how fast fade-in and fade-out animations are.
    * @static
    * @property FADE_TIME
    * @type Number
    * @default 180
    *###
    @FADE_TIME = 180

    @BUTTON_ACTIONS =
        OK:     "CLOSE"
        CANCEL: "CANCEL"
        NEXT:   "NEXT"
        PREV:   "PREV"

    @BUTTONS =
        OK:     """<div class="button ok locale" data-langkey="ok" />"""
        CANCEL: """<div class="button cancel locale" data-langkey="cancel" />"""
        NEXT:   """<div class="button next locale" data-langkey="next" />"""
        PREV:   """<div class="button prev locale" data-langkey="prev" />"""

    @ACTIONS:
        CLOSE: () ->
            return @close()
        OK: () ->
            @close(true)
            if @onOk instanceof Function
                @onOk()
            return @
        CANCEL: () ->
            @close(true)
            if @onCancel instanceof Function
                @onCancel()
            return @
        CHANGE: (targetState) ->
            return @change(targetState)
        NEXT: () ->
            return @next()
        PREV: () ->
            return @prev()

    @BUTTON_COLORS = [
        "#222222"
        "#9FA39F"
        "#B9BCB9"
        "#D3D5D3"
    ]

    ###*
    * This property defines all themes.
    * @static
    * @property THEMES
    * @type Object
    *###
    @THEMES =
        DEFAULT: "default"
    ###*
    * This property defines the current theme of the StateMachineBox class.
    * @static
    * @property _theme
    * @type String
    * @default THEMES.DEFAULT
    *###
    @_theme = @THEMES.DEFAULT

    @_popups        = []
    @_activePopup   = null
    # only required for checking locale settings
    if DEBUG
        @_localeKeys    = [
            "ok"
            "cancel"
            "next"
            "prev"
        ]
        # iso language codes (https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        @_languageKeys  = [
            "aa", "ab", "ae", "af", "ak", "am", "an", "ar", "as", "av", "ay", "az",
            "ba", "be", "bg", "bh", "bi", "bm", "bn", "bo", "br", "bs",
            "ca", "ce", "ch", "co", "cr", "cs", "cu", "cv", "cy", "da", "de", "dv", "dz",
            "ee", "el", "en", "eo", "es", "et", "eu", "fa", "ff", "fi", "fj", "fo", "fr", "fy",
            "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi", "ho", "hr", "ht", "hu", "hy", "hz",
            "ia", "id", "ie", "ig", "ii", "ik", "io", "is", "it", "iu", "ja", "jv",
            "ka", "kg", "ki", "kj", "kk", "kl", "km", "kn", "ko", "kr", "ks", "ku", "kv", "kw", "ky",
            "la", "lb", "lg", "li", "ln", "lo", "lt", "lu", "lv",
            "mg", "mh", "mi", "mk", "ml", "mn", "mr", "ms", "mt", "my",
            "na", "nb", "nd", "ne", "ng", "nl", "nn", "no", "nr", "nv", "ny", "oc", "oj", "om", "or", "os",
            "pa", "pi", "pl", "ps", "pt", "qu", "rm", "rn", "ro", "ru", "rw",
            "sa", "sc", "sd", "se", "sg", "si", "sk", "sl", "sm", "sn", "so", "sq", "sr", "ss", "st", "su", "sv", "sw",
            "ta", "te", "tg", "th", "ti", "tk", "tl", "tn", "to", "tr", "ts", "tt", "tw", "ty",
            "ug", "uk", "ur", "uz", "ve", "vi", "vo", "wa", "wo", "xh", "yi", "yo", "za", "zh", "zu"

            "en-gb", "en-us", "en-ca", "en-au"
        ]

    @_$cache =
        popup:      $ """<div class="smb">
                            <div class="positioner">
                                <div class="content">
                                    <div class="loader" />
                                    <div class="header">
                                        <div class="headline smb_noselect" />
                                    </div>
                                    <div class="bodyWrapper" />
                                    <div class="navigation" />
                                    <div class="footer" />
                                </div>
                                <div class="close" />
                            </div>
                        </div>"""
        overlay:    $ """<div class="overlay" />"""
        buttons:
            raw:    $ """<div class="button raw" />"""
            ok:     $ """<div class="button ok" data-langkey="ok" />"""
            cancel: $ """<div class="button cancel" data-langkey="cancel" />"""
            next:   $ """<div class="button next" data-langkey="next" />"""
            prev:   $ """<div class="button prev" data-langkey="prev" />"""

    @locale = {}

    ############################################################################################################
    # STATIC METHODS
    ###*
    * This method initializes the StateMachineBox class. For example the default locales are set.
    * @static
    * @public
    * @method init
    * @return {StateMachineBox}
    * @chainable
    *###
    @init: () ->
        @setLocale "en", {
            ok:     "ok"
            cancel: "cancel"
            next:   "next"
            prev:   "previous"
        }
        @setLocale "de", {
            ok:     "ok"
            cancel: "abbrechen"
            next:   "weiter"
            prev:   "zurück"
        }
        return @

    ###*
    * This method finds out which StateMachineBox instance is the front most.
    * It doesn't work if custom styles or css classes are set.
    * @static
    * @public
    * @method getTopMost
    * @return {StateMachineBox}
    *###
    @getTopMost: () ->
        popups = @_popups
        divs = $()

        for popup in popups
            divs = divs.add(popup.div)

        # return the popup whose div is the last visible one (= on top)
        return popups[divs.index(divs.filter(":visible:last"))] or null

    ###*
    * This method finds out which StateMachineBox instance is the front most.
    * It doesn't work if custom styles or css classes are set.
    * @static
    * @protected
    * @method getTopMost
    * @param popup {StateMachineBox}
    * @return {StateMachineBox}
    * @chainable
    *###
    @_setActive: (popup) ->
        @_activePopup = popup
        return @

    ###*
    * This method returns the active StateMachineBox instance or the front most (if none are active).
    * @static
    * @protected
    * @method getActive
    * @return {StateMachineBox}
    *###
    @getActive: () ->
        return @_activePopup or @getTopMost()

    ###*
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
    *###
    @setLocale: (language, values, redraw = true) ->
        if DEBUG
            if language in @_languageKeys
                for key in @_localeKeys when not values[key]?
                    throw new Error("StateMachineBox.setLocale: Missing at least 1 key '#{key}' for locale settings!")

                @locale[language] = values
                if redraw is true
                    popup.redraw() for popup in @_popups
                return @
            throw new Error("StateMachineBox.setLocale: Invalid language '#{language}' given!")

        @locale[language] = values
        if redraw is true
            popup.redraw() for popup in @_popups
        return @

    ###*
    * This method gets the locale value for a given language and and a given key. If no key is specified this method returns the data object for the given language.
    * @static
    * @protected
    * @method getLocale
    * @param language {String}
    * @param key {String}
    * Optional. Default resolves to all data. If given should match a key in StateMachineBox._languageKeys.
    * @return {String}
    *###
    @getLocale: (language, key) ->
        if DEBUG
            if @locale[language]?[key]?
                return @locale[language][key]
            if not key? and @locale[language]?
                console.info "StateMachineBox.getLocale: No key given. Returning all keys for '#{language}'."
                return @locale[language]
            throw new Error("StateMachineBox.getLocale: language '#{language}' not set or key '#{key}' not found!")

        if key?
            return @locale[language][key] or null
        return @locale[language]

    ###*
    * This method can be used to remove unneeded locale data from the memory.
    * @static
    * @method deleteLocale
    * @param language {String}
    * @return {StateMachineBox}
    * @chainable
    *###
    @deleteLocale: (language) ->
        if DEBUG
            if @locale[language]?
                delete @locale[language]
            else
                console.warn "StateMachineBox.deleteLocale: language '#{language}' not set thus can't be deleted!"
            return @

        delete @locale[language]
        return @

    @addTheme: (theme) ->
        if DEBUG
            if not @THEMES[theme]?
                if theme isnt theme.toUpperCase()
                    console.warn "StateMachineBox.addTheme: For consistency it is recommended to use upper case theme names. Theme '#{theme}' will be set anyways."
                @THEMES[theme] = theme
            throw new Error("StateMachineBox.addTheme: Theme '#{theme}' already exists!")

        @THEMES[theme] = theme
        return @

    @setTheme: (theme, redraw = true) ->
        if DEBUG
            if @THEMES[theme]?
                @_theme = @THEMES[theme]
                if redraw is true
                    popup.setTheme(@_theme) for popup in @_popups
                return @
            throw new Error("StateMachineBox.setTheme: Invalid theme '#{theme}' given!")

        @_theme = @THEMES[theme]
        if redraw is true
            popup.setTheme(@_theme) for popup in @_popups
        return @

    ###*
    * This method can be used to add a StateMachineBox to the list of registered instances.
    * @static
    * @protected
    * @method _registerPopup
    * @param popup {StateMachineBox}
    * @return {StateMachineBox}
    * @chainable
    *###
    @_registerPopup: (popup) ->
        if popup not in @_popups
            @_popups.push popup
        return @

    ###*
    * This method can be used to remove a StateMachineBox from the list of registered instances.
    * @static
    * @protected
    * @method _unregisterPopup
    * @param popup {StateMachineBox}
    * @return {StateMachineBox}
    * @chainable
    *###
    @_unregisterPopup: (popup) ->
        @_popups = (p for p, i in @_popups when p isnt popup)
        return @

    ############################################################################################################
    # CONSTRUCTOR (+ PSEUDO CONSTRUCTORS)
    @new: (stateMachineConfig, headline, options = {}) ->
        return new @(stateMachineConfig, headline, options)

    # TODO: optional passing of array of contents for linear states
    # TODO: optional passing of differently structured stateMachineConfig: more automization so either events are implicit or states are implicit (depening on what the user might need)
    constructor: (stateMachineConfig, headline, options = {}) ->
        if DEBUG
            if not stateMachineConfig? or not stateMachineConfig.events?
                throw new Error("StateMachineBox::constructor: No (valid) state machine configuration given!")
            # check for naming collisions
            for event in stateMachineConfig.events when @[event.name]?
                throw new Error("StateMachineBox::constructor: Trying to create event '#{event.name}' but that property already exists in popup!!")
            for callbackName, callback of stateMachineConfig.callbacks when @[callbackName]?
                throw new Error("StateMachineBox::constructor: Trying to create callback '#{callbackName}' but that property already exists in popup!!")

        @headline           = headline
        @options            = options
        @closeButtonAction  = options.closeButtonAction or "close"
        @onClose            = options.onClose
        @onOk               = options.onOk
        @onCancel           = options.onCancel
        @onNext             = options.onNext
        @onPrev             = options.onPrev
        @onChange           = options.onChange
        @beforeClose        = options.beforeClose
        @beforeNext         = options.beforeNext
        @beforePrev         = options.beforePrev
        @beforeChange       = options.beforeChange
        @onFailure          = options.onFailure

        @theme              = options.theme or "default"
        @locale             = options.locale or "en"
        @showNavigation     = options.showNavigation or false
        @container          = options.container or $(document.body)

        @data       =
            eventPath: []
        @_drawn     = false

        @div        = @constructor._$cache.popup.clone().addClass(@theme)
        @overlay    = @constructor._$cache.overlay.clone()

        if (width = options.width)? and (height = options.height)?
            # if typeof width is "string"
            #     if width is "auto"

            @div.css {
                width: width
                height: height
            }

        @loader     = null

        # taken from Popup.sass.erb
        @bodyWidth = parseFloat(@options.width) or 800
        @bodyPadding =
            top:    10
            right:  40
            bottom: 10
            left:   40

        @_active = false

        # apply state machine to only this instance
        stateMachineConfig.target = @

        # indicates whether or not the state machine can be linearized:
        #       state1.1
        #       /       \
        # initial       final
        #       \       /
        #       state1.2
        # can also be made linear => 2 options => initial -> state1.1 -> final OR initial -> state1.2 -> final

        @stateMachineConfig = stateMachineConfig
        @bodyWrapper        = null
        @contents           = {}
        for event in stateMachineConfig.events when event.content?
            @contents[event.to] = event.content

        self = @
        if not stateMachineConfig.callbacks?
            stateMachineConfig.callbacks = {}
        stateMachineConfig.callbacks.onenterstate = (event, from, to, params...) ->
            console.log "onenterstate", arguments
            if self.beforeChange instanceof Function and self.beforeChange(to) is false
                return false

            self._changeContent(event, from, to)
            self.data.eventPath.push event
            self.onChange?(event, from, to)
            return true

        # go!
        StateMachine.create stateMachineConfig

        # register popup for possible singleton behavior
        @constructor._registerPopup(@)

    ###*
    * This method sets the current StateMachineBox instance as currently active.
    * @protected
    * @method _setAsActive
    * @return {StateMachineBox}
    * @chainable
    *###
    _setAsActive: () ->
        @constructor._setActive(@)
        return @

    ###*
    * This method show the instance's div.
    * @method show
    * @return {StateMachineBox}
    * @chainable
    *###
    show: (callback) ->
        @div.fadeIn(@constructor.FADE_TIME, callback)
        return @

    ###*
    * This method hides the instance's div.
    * @method hide
    * @return {StateMachineBox}
    * @chainable
    *###
    hide: (callback) ->
        @div.fadeOut(@constructor.FADE_TIME, callback)
        return @

    ###*
    * This method shows the instance's overlay.
    * @method showOverlay
    * @return {StateMachineBox}
    * @chainable
    *###
    showOverlay: (callback) ->
        @overlay.fadeIn(@constructor.FADE_TIME, callback)
        return @

    ###*
    * This method hides the instance's overlay.
    * @method hideOverlay
    * @return {StateMachineBox}
    * @chainable
    *###
    hideOverlay: (callback) ->
        @overlay.fadeOut(@constructor.FADE_TIME, callback)
        return @

    ###*
    * This method shows the instance's ajax loader.
    * @method showLoader
    * @return {StateMachineBox}
    * @chainable
    *###
    showLoader: () ->
        @loader.fadeIn(@constructor.FADE_TIME)
        return @

    ###*
    * This method hides the instance's ajax loader.
    * @method hideLoader
    * @return {StateMachineBox}
    * @chainable
    *###
    hideLoader: () ->
        @loader.fadeOut(@constructor.FADE_TIME)
        return @

    # ACTION STUFF
    ###*
    * This method triggers an action (one of StateMachineBox.ACTIONS).
    * Those actions are a subset of all events.
    * @method fireAction
    * @param name {string}
    * The name of the action.
    * @param params... {mixed}
    * Optional. Any parameter will be passed to the action.
    * @return {mixed}
    *###
    fireAction: (name, params...) ->
        name = name.toUpperCase()
        if (action = @constructor.ACTIONS[name])?
            return action.apply(@, params)
        if DEBUG
            throw new Error("Popup::fireAction: No action with name '#{name}' found!")
        return null

    ###*
    * This method hides the instance's ajax loader.
    * @method close
    * @param ignoreCallback {Boolean}
    * Optional. Default is false. Indicates if the beforeClose and onClose callbacks will be called.
    * @return {StateMachineBox}
    * @chainable
    *###
    close: (ignoreCallback = false) ->
        if not ignoreCallback and @beforeClose instanceof Function and @beforeClose() is false
            return false

        self = @

        @hide () ->
            self.div.remove()
            return true
        @hideOverlay () ->
            self.overlay.remove()
            return true

        @constructor._unregisterPopup(@)

        if not ignoreCallback
            @onClose?()

        return @

    ###*
    * Synonym for close.
    * @method remove
    *###
    remove: () ->
        return @close.apply(@, arguments)

    ###*
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
    *###
    # TODO: different animations: slide, fade, fade through color, immediate
    # TODO: or custom function called on the object
    _changeContent: (event, from, to) ->
        body = $ """<div class="body" style="width: #{@bodyWidth - @bodyPadding.left - @bodyPadding.right}px;" />"""
        content = @contents[to]

        if not content?
            throw new Error("StateMachineBox::_changeContent: No content given for '#{to}'!")

        if not @bodyWrapper?
            @bodyWrapper = @div.find(".bodyWrapper")

        body.append content

        # animate backwards
        if event is "back"
            @bodyWrapper.prepend(body)
                        .css "margin-left", "-#{@bodyWidth}px"
                        .animate(
                            {
                                "margin-left": "0px"
                            }
                            400
                            "swing"
                            () ->
                                $(@).children().eq(1)
                                    .detach()
                                return true
                        )
        # animate forward
        else if from isnt "none"
            @bodyWrapper
                .append(body)
                .animate(
                    {
                        "margin-left": "-#{@bodyWidth}px"
                    }
                    400
                    "swing"
                    () ->
                        $(@).children().eq(0)
                            .detach()
                        $(@).css("margin-left", "0px")
                        return true
                )

        return @

    ###*
    * This method returns the content associated with the current state.
    * @method currentContent
    * @return {StateMachineBox}
    * @chainable
    *###
    currentContent: () ->
        return @contents[@current]

    getLocale: (key) ->
        return @constructor.getLocale(@locale, key)

    ###*
    * This method draws the StateMachineBox instance to the DOM.
    * @method draw
    * @return {StateMachineBox}
    * @chainable
    *###
    draw: () ->
        if @constructor.MODE is @constructor.MODES.SINGLE and @constructor.getActive()?
            console.warn "Popup::draw: tried to draw more than 1 popup but mode is set to 'single'!"
            return @

        if @_drawn is true
            console.warn "Popup::draw: tried to draw same StateMachineBox instance more than once!"
            return @

        self = @

        # if @headline
        #     headlineDiv = """<div class="header companyBGColor">
        #                         <div class="headline smb_noselect">#{@headline}</div>
        #                     </div>"""
        # else
        #     headlineDiv = ""

        @div.find(".headline").append @headline

        # @div.empty()
        #     .append """<div class="content">
        #                 <div class="close" />
        #                 <div class="loader" />
        #                 #{headlineDiv}
        #                 <div class="bodyWrapper" />
        #                 <div class="navigation" />
        #                 <div class="footer" />
        #             </div>"""

        # close buutton
        @div.find(".overlay, .close").click () ->
            self.fireAction(self.closeButtonAction)
            return true

        # click => mark as most recently active popup
        @div.mousedown () ->
            self._setAsActive()
            return true

        @navigation = @div.find(".navigation")
        @loader     = @div.find(".loader")
        @footer     = @div.find(".footer")

        # create standard buttons (at bottom)
        buttons = @options.buttons or []

        for button, idx in buttons when button?
            action = null
            # just button key => use default
            if typeof button is "string"
                b = button.toLowerCase()
                button = @constructor._$cache.buttons[b].clone()
                action = @constructor.ACTIONS[@constructor.BUTTON_ACTIONS[b]]
            # special config given => use that config
            else if button.button? and button.action?
                b = button
                button = @constructor._$cache.buttons[b.button.toLowerCase()].clone()
                event = @constructor.ACTIONS[b.action.toLowerCase()]
            else if button.event? and button.label?
                if DEBUG
                    if not @[button.event]?
                        console.warn "StateMachineBox::draw: Invalid button configuration for StateMachineBox! Invalid button event '#{button.event}'!", @options.buttons
                        continue

                b = button
                button = @constructor._$cache.buttons.raw.clone()
                if b.locale is true
                    button.text @getLocale(b.label)
                else
                    button.text b.label
                event = @[b.event]
            # invalid
            else if DEBUG
                button = null

            if DEBUG
                if not button?
                    console.warn "StateMachineBox::draw: Invalid button configuration for StateMachineBox!", @options.buttons
                    continue

            if event?
                # button = $ button
                lastColor = @constructor.BUTTON_COLORS[idx]
                button.css {
                    "background-color": lastColor
                }
                do (event) ->
                    button.click () ->
                        event.call(self)
                        return true
                @footer.append button

        # set footer bg color to last button color
        @footer.css "background-color", lastColor

        self = @

        if not @showNavigation
            @navigation.addClass "hidden"

        # TODO:
        @init()

        # draw only initial content and pre- or append contents as needed (depending on event)
        content = @contents[@current]

        if not content?
            throw new Error("StateMachineBox::draw: No content found for '#{@current}'!")

        body = $ """<div class="body" style="width: #{@bodyWidth - @bodyPadding.left - @bodyPadding.right}px;" />"""
        body.append content
        @bodyWrapper.append body

        if @constructor.MODE is @constructor.MODES.MANY
            @div
                .draggable {
                    handle: ".header"
                }
                .addClass "draggable"
        else if @constructor.MODE is @constructor.MODES.SINGLE
            @container.append @overlay.click () ->
                self.fireAction("cancel")
                return true

        @container.append @div
        @_setAsActive()

        return @

    ###*
    * This method redraws the StateMachineBox instance.
    * This does not actually redraw everything but resets the texts of elements containing locale data.
    * @method redraw
    * @return {StateMachineBox}
    * @chainable
    *###
    redraw: () ->
        elems = @div.find(".locale")
        for key, val of @contructor.getLocale(@locale)
            elems.filter("[data-langkey=\"#{key}\"]").text val

        return @

    ###*
    * This method redraws the StateMachineBox instance.
    * This does not actually redraw everything but resets the theme css classes of the according elements.
    * @method redraw
    * @return {StateMachineBox}
    * @chainable
    *###
    setTheme: (theme) ->
        if @theme isnt theme
            @div.find(".#{@theme}").removeClass(@theme).addClass(theme)
        return @

    # EVENT (STATE MACHINE) STUFF
    ###*
    * This method triggers an event. If the event is invalid for the current state onFailure will be called.
    * This method might seem a bit unnecessary but implicit event function calls might appear weird and this method has better error reporting.
    * @method fireEvent
    * @param name {String}
    * The name of the event to trigger.
    * @param params... {mixed}
    * Optional. Any parameter will be passed to the event callback.
    * @return {StateMachineBox}
    * @chainable
    *###
    fireEvent: (name, params...) ->
        if @[name] instanceof Function
            @[name](params...)
            return @
        console.warn "StateStatePopup::fireEvent: There is no event called '#{name}'! Use onFailure() to catch that!"
        @onFailure?(name)
        return @

    # ACTION STUFF
    ###*
    * This method is a convenience method for fireEvent. If the state allows only 1 event this method will trigger that event.
    * @method next
    * @return {StateMachineBox}
    * @chainable
    *###
    next: () ->
        if @beforeNext instanceof Function and @beforeNext() is false
            return @

        foundEvents = []
        # ignore "back" because we're looking for next contents here!
        for event in @stateMachineConfig.events when event.from is @current and event.name isnt "back"
            foundEvents.push event

        if foundEvents.length is 1
            @fireEvent(foundEvents.first.name)
            return @

        if foundEvents.length is 0
            console.warn "StateMachineBox::next: There is no event for '#{@current}'! Can't go any further! Use onFailure() to catch that!"
            @onFailure?("next")
            return @

        console.warn "StateMachineBox::next: More than 1 event for '#{@current}': [#{event.name for event in foundEvents}]! Can't decide where to go! Use onFailure() to catch that!"
        @onFailure?("next")
        return @

    ###*
    * This method is a convenience method for fireEvent (just like next). The difference here is that the state machine has no direction so next and prev are indistinguishable. Therefore the state machine must have a 'back' event for all states that are supposed to allow prev.
    * Only if there is exactly 1 other state that has an event that changes to the current state, prev can be applied.
    * @method prev
    * @return {StateMachineBox}
    * @chainable
    *###
    prev: () ->
        if @beforePrev instanceof Function and @beforePrev() is false
            return @
        try
            @back()
            return @
        catch e
            # TODO: try to find definite previous state
            console.warn "StateMachineBox::prev: Cannot go to 'prev' because no back route was defined! Define it with '{ name: 'back', from: 'prevState', to: 'returnState' }' ;) Use onFailure() to catch that!"
            console.warn e
            @onFailure?("prev")
            return @

    # NOTE: this method should not be necessary because it semantically equals fireEvent...
    # ###*
    # * This method is a convenience method for fireEvent (just like next). The difference here is that the state machine has no direction so next and prev are indistinguishable. Therefore the state machine must have a 'back' event for all states that are supposed to allow prev.
    # * Only if there is exactly 1 other state that has an event that changes to the current state, prev can be applied.
    # * @method change
    # * @param targetState {String}
    # * @return {StateMachineBox}
    # * @chainable
    # *###
    # change: (targetState) ->
    #     if @beforeChange instanceof Function and @beforeChange(targetState) is false
    #         return @
    #
    #     for event in @stateMachineConfig.events when event.from is @current and event.to is targetState
    #         @fireEvent(event.name)
    #         if @onChange instanceof Function
    #             @onChange.call(@, event.from, targetState)
    #         return @
    #
    #     console.warn "StateMachineBox::change: Cannot go to '#{targetState}' from '#{@current}'! Use onFailure() to catch that!"
    #     @onFailure?("change")
    #     return @

# set locale
StateMachineBox.init()
