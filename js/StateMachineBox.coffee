###*
* @class StateMachineBox
*
* @constructor
*
*###
class window.StateMachineBox

    @MODES =
        SINGLE: "single"
        MANY:   "many"
    @MODE       = @MODES.SINGLE
    @FADE_TIME  = 180

    @DEFAULT_CSS_CLASS = "default"

    @BUTTON_ACTIONS =
        OK:     "CLOSE"
        CANCEL: "CANCEL"
        NEXT:   "NEXT"
        PREV:   "PREV"

    @BUTTONS =
        OK:     """<div class="button ok">ok</div>"""
        CANCEL: """<div class="button cancel">cancel</div>"""
        NEXT:   """<div class="button next">next</div>"""
        PREV:   """<div class="button prev">prev</div>"""

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
        CHANGE: (idx) ->
            return @change(idx)
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
        ]

    @_$cache =
        popup:      $ """<div class="popup">
                            <div class="content">
                                <div class="close" />
                                <div class="loader" />
                                <div class="header">
                                    <div class="headline" />
                                </div>
                                <div class="bodyWrapper" />
                                <div class="navigation" />
                                <div class="footer" />
                            </div>
                        </div>"""
        overlay:    $ """<div class="popup overlay" />"""

    @locale = {}

    ############################################################################################################
    # STATIC METHODS
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

    @getTopMost = () ->
        popups = @_popups
        divs = $()

        for popup in popups
            divs = divs.add(popup.div)

        # return the popup whose div is the last visible one (= on top)
        return popups[divs.index(divs.filter(":visible:last"))] or null

    @_setActive: (popup) ->
        @_activePopup = popup
        return @

    @getActive: () ->
        return @_activePopup or @getTopMost()

    @setLocale: (language, values, redraw = true) ->
        if DEBUG
            if language in @_languageKeys
                for key in @_localeKeys when not values[key]?
                    throw new Error("StateMachineBox.setLocale: Missing at least 1 key '#{key}' for locale settings!")

                @locale[language] = values
                popup.redraw() for popup in @_popups
                return @
            throw new Error("StateMachineBox.setLocale: Invalid language '#{language}' given!")

        @locale[language] = values
        popup.redraw() for popup in @_popups
        return @

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

    @registerPopup: (popup) ->
        if popup not in @_popups
            @_popups.push popup
        return @

    @unregisterPopup: (popup) ->
        @_popups = (p for p, i in @_popups when p isnt popup)
        return @

    ############################################################################################################
    # CONSTRUCTOR (+ PSEUDE CONSTRUCTORS)
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

        @data       = {}

        @div        = @constructor._$cache.popup.clone()
        @overlay    = @constructor._$cache.overlay.clone()

        if options.width? and options.height?
            @div.css {
                width: options.width
                height: options.height
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

            self.changeContent(event, from, to)
            return true

        # go!
        StateMachine.create stateMachineConfig

        # register popup for possible singleton behavior
        @constructor.registerPopup(@)

    _setAsActive: () ->
        @constructor._setActive(@)
        return @

    show: (callback) ->
        @div.fadeIn(FADE_TIME, callback)
        return @

    hide: (callback) ->
        @div.fadeOut(FADE_TIME, callback)
        return @

    showOverlay: (callback) ->
        @overlay.fadeIn(FADE_TIME, callback)
        return @

    hideOverlay: (callback) ->
        @overlay.fadeOut(FADE_TIME, callback)
        return @

    showLoader: () ->
        @loader.fadeIn(FADE_TIME)
        return @

    hideLoader: () ->
        @loader.fadeOut(FADE_TIME)
        return @

    # ACTION STUFF
    fireAction: (name, params...) ->
        name = name.toUpperCase()
        if (action = @constructor.ACTIONS[name])?
            return action.apply(@, params)
        throw new Error("Popup::fireAction: No action with name '#{name}' found!")

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

        @constructor.unregisterPopup(@)

        if not ignoreCallback
            @onClose?()

        return @

    remove: () ->
        return @close.apply(@, arguments)

    # TODO; different animations: slide, fade, fade through color, immediat
    changeContent: (event, from, to) ->
        body = $ """<div class="body" style="width: #{@bodyWidth - @bodyPadding.left - @bodyPadding.right}px;" />"""
        content = @contents[to]

        if not content?
            throw new Error("StateMachineBox::changeContent: No content given for '#{to}'!")

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

    currentContent: () ->
        return @contents[@current]

    draw: () ->
        if @constructor.MODE is @constructor.MODES.SINGLE and @constructor.getActive()?
            console.warn "Popup::draw: tried to draw more than 1 popup but mode is set to 'single'!"
            return @

        self = @

        if @headline
            headlineDiv = """<div class="header companyBGColor">
                                <div class="headline noselect">#{@headline}</div>
                            </div>"""
        else
            headlineDiv = ""

        @div.empty()
            .append """<div class="content">
                        <div class="close" />
                        <div class="loader" />
                        #{headlineDiv}
                        <div class="bodyWrapper" />
                        <div class="navigation" />
                        <div class="footer" />
                    </div>"""

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
                b = button.toUpperCase()
                button = @constructor.BUTTONS[b]
                action = @constructor.ACTIONS[@constructor.BUTTON_ACTIONS[b]]
            # special config given => use that config
            else if button.button? and button.action?
                b = button
                button = @constructor.BUTTONS[b.button.toUpperCase()]
                action = @constructor.ACTIONS[b.action.toUpperCase()]
            # invalid
            else
                console.warn "Invalid button configuration for Popup!"
                continue

            if action?
                button = $ button
                lastColor = @constructor.BUTTON_COLORS[idx]
                button.css {
                    "background-color": lastColor
                }
                do (action) ->
                    button.click () ->
                        action.call(self)
                        return true
                @footer.append button

        # set footer bg color to last button color
        @footer.css "background-color", lastColor

        self = @

        if not @showNavigation
            @navigation.addClass "hidden"

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

    # this does not actually redraw everything but rather the elements containing locale data
    redraw: () ->

        return @

    # EVENT (STATE MACHINE) STUFF
    # this might seem pointless but implicit function calls might appear weird (and here we have better error reporting)
    fireEvent: (name, params...) ->
        if @[name] instanceof Function
            @[name](params...)
            return @
        console.warn "StateStatePopup::fireEvent: There is no event called '#{name}'! Use onFailure() to catch that!"
        @onFailure?(name)
        return @

    # ACTION STUFF
    next: () ->
        if @beforeNext instanceof Function and @beforeNext() is false
            return false

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

    prev: () ->
        if @beforePrev instanceof Function and @beforePrev() is false
            return false
        try
            @back()
            return @
        catch e
            console.warn "StateMachineBox::prev: Cannot go to 'prev' because no back route was defined! Define it with '{ name: 'back', from: 'prevState', to: 'returnState' }' ;) Use onFailure() to catch that!"
            console.warn e
            @onFailure?("prev")
            return @

    change: (targetState) ->
        if @beforeChange instanceof Function and @beforeChange(idx) is false
            return false

        for event in @stateMachineConfig.events when event.from is @current and event.to is targetState
            @fireEvent(event.name)
            if @onChange instanceof Function
                @onChange.call(@, event.from, targetState)
            return @

        console.warn "StateMachineBox::change: Cannot go to '#{targetState}' from '#{@current}'! Use onFailure() to catch that!"
        @onFailure?("change")
        return @

# set locale
StateMachineBox.init()
