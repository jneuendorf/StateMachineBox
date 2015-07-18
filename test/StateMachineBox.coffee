describe "StateMachineBox", () ->

    images = [
        "<img src='img/closeup.jpg' />"
        "<img src='img/clouds.jpg' />"
        "<img src='img/little-tree.jpg' />"
        "<img src='img/moon.jpg' />"
        "<img src='img/nature-wlk.jpg' />"
        "<img src='img/nature1.jpg' />"
        "<img src='img/sun-flowers.jpg' />"
        "<img src='img/sun1.jpg' />"
    ]

    config =
        events: [
            # initial content
            { name: "init", from: "none", to: "initial", content: images[0] }

            { name: "left", from: "initial", to: "left", content: images[1] }
            { name: "right", from: "initial", to: "right", content: images[2] }
            { name: "back", from: "left", to: "initial" }
            { name: "back", from: "right", to: "initial" }

            { name: "left", from: "left", to: "left_left", content: images[3] }
            { name: "right", from: "left", to: "left_right", content: images[4] }
            { name: "back", from: "left_left", to: "left" }
            { name: "back", from: "left_right", to: "left" }

            { name: "left", from: "left_left", to: "left_left_left", content: images[5] }
            { name: "right", from: "left_left", to: "left_left_right", content: images[6] }
            { name: "back", from: "left_left_left", to: "left_left" }
            { name: "back", from: "left_left_right", to: "left_left" }

            { name: "left", from: "left_left_left", to: "final", content: images[7] }
            { name: "left", from: "left_left_right", to: "final" }
            { name: "left", from: "left_right", to: "final" }
            { name: "right", from: "left_left_left", to: "final" }
            { name: "right", from: "left_left_right", to: "final" }
            { name: "right", from: "left_right", to: "final" }
        ]
        # TODO: move possible callbacks of state machine js to statemachineconfig: ie. onbeforeevent should be able to be put into the StateMachineBox ctor options
        # callbacks:
        #     onbeforeevent: () ->
        #         console.log arguments

    it "singleton-like behavior", () ->
        StateMachineBox.MODE = StateMachineBox.MODES.SINGLE

        popup = new StateMachineBox(config, null, {
            buttons: [
                {
                    event: "left"
                    label: "left"
                    locale: false
                }
                {
                    event: "right"
                    label: "right"
                    locale: false
                }
                {
                    event: "back"
                    label: "back"
                    locale: false
                }
            ]
            # closeButtonAction: "cancel"
            width: "700px"
            height: "630px"
            # onClose: () ->
            #     startRendering(favIds, renderOptions, folderName)
            callbacks:
                onFailure: (event) ->
                    console.warn event
                    return true
        })
        popup.draw()

        console.log popup

        # check if we get here
        expect(true).toBe(true)


        # CHECK SINGLETON BEHAVIOR
        popup2 = new StateMachineBox(config, null, {
            buttons: [
                {
                    event: "left"
                    label: "left"
                    locale: false
                }
                {
                    event: "right"
                    label: "right"
                    locale: false
                }
                {
                    event: "back"
                    label: "back"
                    locale: false
                }
            ]
            # closeButtonAction: "cancel"
            width: "700px"
            height: "630px"
            # onClose: () ->
            #     startRendering(favIds, renderOptions, folderName)
            callbacks:
                onFailure: (event) ->
                    console.warn event
                    return true
        })

        popup2.draw()

        expect popup2.div.is(":visible")
            .toBe false

        console.log popup2



    it "multiple-like behavior", () ->
        StateMachineBox.MODE = StateMachineBox.MODES.MANY

        popup = new StateMachineBox(config, null, {
            buttons: [
                {
                    event: "left"
                    label: "left"
                    locale: false
                }
                {
                    event: "right"
                    label: "right"
                    locale: false
                }
                {
                    event: "back"
                    label: "back"
                    locale: false
                }
            ]
            # closeButtonAction: "cancel"
            width: "700px"
            height: "630px"
            # onClose: () ->
            #     startRendering(favIds, renderOptions, folderName)
            callbacks:
                onFailure: (event) ->
                    console.warn event
                    return true
        })
        popup.draw()

        console.log popup

        # check if we get here
        expect(true).toBe(true)
