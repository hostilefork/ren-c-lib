REBOL [
    Title: "Lest (preprocessed)"
]
plugin-cache: [google-analytics [
        rule: use [value web] [
            [
                'ga
                set value word!
                set web word!
                (
                    debug ["==GOOGLE ANALYTICS:" value web]
                    append includes/body-end reword {
^-<script>
^-  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
^-  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
^-  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
^-  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

^-  ga('create', '$value', '$web');
^-  ga('send', 'pageview');

^-</script>
^-} [
                        'value value
                        'web web
                    ]
                )
            ]
        ]
    ] password-strength [
        startup: [
            append script js-path/pwstrength.js
        ]
        rule: rule [verdicts too-short same-as-user username] [
            'password-strength
            (
                verdicts: ["Weak" "Normal" "Medium" "Strong" "Very Strong"]
                too-short: "<font color='red'>The Password is too short</font>"
                same-as-user: "Your password cannot be the same as your username"
                username: "username"
            )
            any [
                'username
                set username word!
                | 'verdicts
                set verdicts block!
                | 'too-short
                set too-short string!
                | 'same-as-user
                set same-as-user string!
            ]
            (
                append includes/body-end trim/lines reword
                {<script type="text/javascript">
jQuery(document).ready(function () {
^-"use strict";
^-var options = {
^-^-minChar: 8,
^-^-bootstrap3: true,
^-^-errorMessages: {
^-^-    password_too_short: "$too-short",
^-^-    same_as_username: "$same-as-user"
^-^-},
^-^-scores: [17, 26, 40, 50],
^-^-verdicts: [$verdicts],
^-^-showVerdicts: true,
^-^-showVerdictsInitially: false,
^-^-raisePower: 1.4,
^-^-usernameField: "#$username",
^-};
^-$(':password').pwstrength(options);
});
</script>}
                compose [
                    verdicts (catenate/as-is verdicts ", ")
                    too-short (too-short)
                    same-as-user (same-as-user)
                    username (username)
                ]
            )
        ]
    ] bootstrap [
        startup: [
            stylesheet css-path/bootstrap.min.css
            append script js-path/jquery-2.1.0.min.js
            append script js-path/bootstrap.min.js
        ]
        rule: [
            grid-elems
            | col
            | bar
            | panel
            | glyphicon
            | address
            | dropdown
            | carousel
            | modal
            | navbar
            | end
        ]
        grid-elems: [
            set type ['row | 'container]
            init-div
            opt style
            (insert tag/class type)
            emit-tag
            into [some elements]
            close-div
        ]
        col: use [grid-size width offset] [
            [
                'col
                (
                    grid-size: 'md
                    width: 2
                    offset: none
                )
                init-div
                some [
                    'offset set offset integer!
                    | set grid-size ['xs | 'sm | 'md | 'lg]
                    | set width integer!
                ]
                opt style
                (
                    append tag/class rejoin ["col-" grid-size "-" width]
                    if offset [
                        append tag/class rejoin ["col-" grid-size "-offset-" offset]
                    ]
                )
                emit-tag
                into [some elements]
                close-div
            ]
        ]
        bar: ['bar (print "ahoj!")]
        panel: [
            'panel
            (
                tag-name: 'div
                panel-type: 'default
            )
            init-tag
            opt [
                [not ['heading | 'footer]]
                and
                [set panel-type word!]
                skip
            ]
            (
                repend tag/class [
                    'panel
                    to word! join 'panel- panel-type
                ]
            )
            emit-tag
            any [
                [
                    'heading
                    init-div
                    (append tag/class 'panel-heading)
                    emit-tag
                    [
                        set value string!
                        (value-to-emit: ajoin [<h3 class="panel-title"> value </h3>])
                        emit-value
                        | into [some elements]
                    ]
                    end-tag
                ]
                | [
                    'footer
                    init-div
                    (append tag/class 'panel-footer)
                    emit-tag
                    into [some elements]
                    end-tag
                ]
            ]
            into [some elements]
            end-tag
        ]
        glyphicon: [
            'glyphicon
            set name word!
            (tag-name: 'span)
            init-tag
            (
                repend tag/class ['glyphicon join 'glyphicon- name]
                debug ["==GLYPHICON: " name]
            )
            emit-tag
            end-tag
        ]
        address: [
            'address
            (
                emit <address>
                first-line?: true
            )
            into [
                some [
                    set value string! (
                        emit rejoin either first-line? [
                            first-line?: false
                            ["" <strong> value </strong> <br>]
                        ] [
                            [value <br>]
                        ]
                    )
                    | 'email set value string! (
                        emit rejoin [{<a href="mailto:} value {">} value </a> <br>]
                    )
                    | 'phone set value string! (
                        emit rejoin ["" <abbr title="Telefon"> "Tel: " </abbr> value <br>]
                    )
                ]
            ]
            (emit </address>)
        ]
        navbar: [
            'navbar
            init-div
            (
                append tag/class [navbar navbar-fixed-top navtext]
                append tag [role: navigation]
            )
            some [
                'inverse (append tag/class 'navbar-inverse)
                | style
            ]
            emit-tag
            (emit [
                    <div class="container">
                    <div class="navbar-collapse collapse">
                    <ul id="page-nav" class="nav navbar-nav">
                ])
            into [
                some [
                    'link (active?: false)
                    opt ['active (active?: true)]
                    set target [file! | url! | issue!]
                    set value string!
                    (emit ajoin [
                            "<li"
                            either active? [{ class="active">}] [#">"]
                            {<a href="} target {">} value
                            </a>
                            </li>
                        ])
                ]
            ]
            (emit [</ul> </div> </div>])
            end-tag
        ]
        carousel: [
            'carousel
            init-tag
            (
                debug "==CAROUSEL"
                tag-name: 'div
                append tag compose [
                    inner-html: (copy "")
                    items: 0
                    active: 0
                    data-ride: carousel
                    class: [carousel slide]
                ]
                carousel-menu: none
            )
            set name word!
            (tag/id: name)
            any [
                style
                | 'no 'indicators (carousel-menu: false)
                | 'indicators set carousel-menu block!
            ]
            into [some carousel-item]
            take-tag
            (
                if none? carousel-menu [
                    carousel-menu: copy [ol #carousel-indicators]
                    repeat i tag/items [
                        append carousel-menu reduce [
                            'li 'with compose [
                                data-target: (to issue! tag/id)
                                data-slide-to: (i - 1)
                                (either i = tag/active [[class: active]] [])
                            ]
                            ""
                        ]
                    ]
                ]
                data: tag/inner-html
                tag/items:
                tag/active:
                tag/inner-html: none
                emit [
                    build-tag tag-name tag
                    either carousel-menu [
                        lest carousel-menu
                    ] [
                        ""
                    ]
                    <div class="carousel-inner">
                    data
                    </div>
                    lest compose [
                        a (to file! to issue! tag/id) #left #carousel-control with [data-slide: prev] [glyphicon chevron-left]
                        a (to file! to issue! tag/id) #right #carousel-control with [data-slide: next] [glyphicon chevron-right]
                    ]
                    close-tag 'div
                ]
            )
        ]
        carousel-item: [
            'item
            (active?: false)
            opt [
                'active
                (active?: true)
            ]
            set data block!
            (
                append tag/inner-html rejoin [
                    {<div class="item}
                    either active? [" active"] [""]
                    {">}
                    lest data
                    </div>
                ]
                tag/items: tag/items + 1
                if active? [tag/active: tag/items]
            )
        ]
        dropdown: [
            'dropdown
            init-div
            copy label string!
            (
                tag/class: [btn-group]
                emit [
                    build-tag tag-name tag
                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                    label
                    <span class="caret"> </span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                ]
            )
            some [
                menu-item
                | menu-divider
            ]
            (emit close-tag 'ul)
            close-div
        ]
        menu-item: [
            set label string!
            set target [file! | url!]
            (emit [{<li><a href="} target {">} label "</a></li>"])
        ]
        menu-divider: [
            'divider
            (emit ["" <li class="divider"> </li>])
        ]
        modal: [
            'modal
            init-tag
            (label: 'modal-label)
            set name word!
            opt ['label set label word!]
            (
                debug "==MODAL"
                tag-name: 'div
                tag/id: name
                append tag/class [modal fade]
                append tag [
                    tabindex: -1
                    role: dialog
                    aria-labelledby: label
                    aria-hidden: true
                ]
            )
            emit-tag
            init-div
            (append tag/class 'modal-dialog)
            emit-tag
            init-div
            (append tag/class 'modal-content)
            emit-tag
            opt modal-header
            modal-body
            opt modal-footer
            end-tag
            end-tag
            end-tag
        ]
        modal-header: [
            'header
            init-div
            (
                append tag/class 'modal-header
                emit [
                    build-tag tag-name tag
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times
                    </button>
                ]
            )
            into [some elements]
            end-tag
        ]
        modal-body: [
            opt 'body
            init-div
            (append tag/class 'modal-body)
            emit-tag
            into [some elements]
            end-tag
        ]
        modal-footer: [
            'header
            init-div
            (append tag/class 'modal-footer)
            emit-tag
            into [some elements]
            end-tag
        ]
    ] markdown [
        startup: [
            debug "==ENABLE MARKDOWN"
            do %md.reb
        ]
        rule: [
            'markdown
            set value string! (emit markdown value)
        ]
    ] smooth-scrolling [
        startup: [
            debug "==ENABLE SMOOTH SCROLLING"
            append script {
^-  $(function() {
^-    $('ul#page-nav > li > a[href*=#]:not([href=#])').click(function() {
^-      if (location.pathname.replace(/^^\//,'') == this.pathname.replace(/^^\//,'') && location.hostname == this.hostname) {

^-        var target = $(this.hash);
^-        var navHeight = $("#page-nav").height();

^-        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
^-        if (target.length) {
^-          $('html,body').animate({
^-            scrollTop: target.offset().top - navHeight
^-          }, 1000);
^-          return false;
^-        }
^-      }
^-    });
^-  });
^-}
        ]
    ] pretty-photo [
        startup: [
            append script js-path/jquery.prettyPhoto.js
            append script {
^-  $(document).ready(function(){
^-    $("a[rel='prettyPhoto']").prettyPhoto();
^-  });
^-}
        ]
    ] captcha [
        rule: [
            'captcha set value string! (
                emit reword {
<script type="text/javascript" src="http://www.google.com/recaptcha/api/challenge?k=$public-key"></script>
<noscript>
<iframe src="http://www.google.com/recaptcha/api/noscript?k=$public-key" height="300" width="500" frameborder="0"></iframe>
<br>
<textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
<input type="hidden" name="recaptcha_response_field" value="manual_challenge">
</noscript>
} reduce ['public-key value]
            )
        ]
    ] font-awesome [
        startup: [
            stylesheet css-path/font-awesome.min.css
        ]
        rule: use [tag name fixed? size value size-att] [
            [
                'fa-icon
                init-tag
                (
                    name: none
                    fixed?: ""
                )
                [
                    'stack set name block!
                    | set name word!
                ]
                (debug ["==FA-ICON:" name])
                any [
                    set size integer!
                    | 'fixed (fixed?: " fa-fw")
                    | 'rotate set value integer!
                    | 'flip set value ['horizontal | 'vertical]
                    | style
                ]
                take-tag
                (
                    tag: rules/tag
                    size-att: case [
                        size = 1 (" fa-lg")
                        size (rejoin [" fa-" size "x"])
                        true ("")
                    ]
                    either word? name [
                        emit rejoin [{<i class="fa fa-} name size-att fixed? " " tag/class {"></i>}]
                    ] [
                        emit rejoin [
                            ""
                            <span class="fa-stack fa-lg">
                            {<i class="fa fa-} first name " fa-stack-2x" fixed? {">} </i>
                            {<i class="fa fa-} second name " fa-stack-1x fa-inverse " fixed? catenate tag/class " " {">} </i>
                            </span>
                        ]
                    ]
                )
            ]
        ]
    ] test [
        startup: [
            stylesheet css-path/bootstrap.min.css
            append script js-path/jquery-2.1.0.min.js
            append script js-path/bootstrap.min.js
        ]
        rule: [
            set type 'crow
            (print ["init.test..." c])
            c
            opt style
            (print "this?" insert tag/class type print "no")
            emit-tag
            close-div
        ]
        c: [init-div]
    ] lightbox [
        startup: [
            stylesheet css-path/bootstrap-lightbox.min.css
            insert script js-path/bootstrap-lightbox.min.js
        ]
    ] google-maps [
        rule: [
            'map
            set location pair!
            (
                emit ajoin [
                    {<iframe width="425" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=cs&amp;geocode=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;z=14&amp;ll=} location/x #"," location/y {&amp;output=embed">}
                    </iframe> <br /> <small>
                    {<a href="https://maps.google.com/maps?f=q&amp;source=embed&amp;hl=cs&amp;geocode=&amp;aq=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;hnear=Mez%C3%ADrka,+Brno,+%C4%8Cesk%C3%A1+republika&amp;z=14&amp;ll=} location/x #"," location/y {" style="color:#0000FF;text-align:left">Zvětšit mapu}
                    </a> </small>
                ]
            )
        ]
    ] wysiwyg [
        startup: [
            stylesheet css-path/bootstrap-wysihtml5.css
            append plugin js-path/wysihtml5-0.3.0.min.js
            append plugin js-path/bootstrap3-wysihtml5.js
            append plugin "$('.wysiwyg').wysihtml5();"
        ]
        rule: [
            'wysiwyg (debug ["==WYSIWYG matched"])
            init-tag
            opt style
            (
                debug ["==WYSIWYG"]
                tag-name: 'textarea
                append tag/class 'wysiwyg
            )
            emit-tag
            end-tag
        ]
    ] google-font [
        startup: [
            stylesheet css-path/bootstrap.min.css
        ]
        rule: [
            'google-font
            set name string!
            (
                debug ["==GFONT:" name]
                repend includes/header [
                    {<link href='http://fonts.googleapis.com/css?family=}
                    replace/all name #" " #"+"
                    {:400,300&amp;subset=latin,latin-ext' rel='stylesheet' type='text/css'>}
                ]
                repend includes/style ['google 'fonts name #400]
            )
        ]
    ]]
to-css: use [ruleset parser ??] [
    ruleset: context [
        values: copy []
        unset: func [key [word!]] [remove-each [k value] values [k = key]]
        set: func [key [word!] value [any-type!]] [
            unset key repend values [key value]
        ]
        colors: copy []
        lengths: copy []
        transitions: copy []
        transformations: copy []
        enspace: func [value] [join " " value]
        form-color: func [value [tuple! word!]] [
            enspace either value/4 [
                ["rgba(" value/1 "," value/2 "," value/3 "," either integer? value: value/4 / 255 [value] [round/to value 0.01] ")"]
            ] [
                ["rgb(" value/1 "," value/2 "," value/3 ")"]
            ]
        ]
        form-number: func [value [number!] unit [word! string! none!]] [
            enspace case [
                value = 0 ["0"]
                unit [join value unit]
                value [form value]
            ]
        ]
        form-value: func [values /local value choices] [
            any [
                switch value: take values [
                    em pt px deg vw vh [form-number take values value]
                    pct [form-number take values "%"]
                    * [form-number take values none]
                    | [","]
                    radial [enspace ["radial-gradient(" remove form-values values ")"]]
                    linear [enspace ["linear-gradient(" remove form-values values ")"]]
                ]
                switch type?/word value [
                    integer! decimal! [form-number value 'px]
                    pair! [rejoin [form-number value/x 'px form-number value/y 'px]]
                    time! [form-number value/second 's]
                    tuple! [form-color value]
                    string! [enspace mold value]
                    url! file! [enspace ["url('" value "')"]]
                    path! [enspace [{url("data:} form value ";base64," enbase/base take values 64 {")}]]
                ]
                enspace value
            ]
        ]
        form-transform: func [transform [block!] /local name direction] [
            switch/default take transform [
                translate [
                    enspace [
                        "translate" uppercase form take transform
                        "(" next form-value transform ")"
                    ]
                ]
                rotate [
                    enspace ["rotate(" next form-value transform ")"]
                ]
                scale [
                    enspace [
                        "scale" either word? transform/1 [uppercase form take transform] [""]
                        "(" next form-number take transform none either tail? transform [""] [
                            "," form-number take transform none
                        ] ")"
                    ]
                ]
            ] [keep mold head insert transform name]
        ]
        form-values: func [values [block!]] [
            rejoin collect [
                while [not tail? values] [keep form-value values]
            ]
        ]
        form-property: func [property [word!] values [string! block!] /vendors /inline prefix] [
            if block? values [values: form-values values]
            rejoin collect [
                if any [vendors found? find [transition box-sizing transform-style transition-delay] property] [
                    foreach prefix [-webkit- -moz- -ms- -o-] [
                        keep form-property to word! join prefix form property values
                    ]
                ]
                if prefix [insert next values prefix]
                keep ["^/^-" property ":" values ";"]
            ]
        ]
        render: has [value] [
            while [value: take lengths] [
                value: compose [(value)]
                case [
                    not find values 'width [set 'width value]
                    not find values 'height [set 'height value]
                ]
            ]
            while [value: take colors] [
                value: compose [(value)]
                case [
                    not find values 'color [set 'color value]
                    not find values 'background-color [set 'background-color value]
                ]
            ]
            rejoin collect [
                keep "{"
                foreach [property values] values [
                    case [
                        find [opacity] property [
                            if tail? next values [insert values '*]
                        ]
                        all [
                            property = 'background-image
                            find [radial linear] values/1
                        ] [
                            foreach prefix [-webkit- -moz- -ms- -o-] [
                                keep form-property/inline property copy values prefix
                            ]
                        ]
                    ]
                    switch/default property [] [
                        keep form-property property values
                    ]
                ]
                foreach transform transformations [
                    transform: form-transform transform
                    keep form-property/vendors 'transform transform
                ]
                unless empty? transitions [
                    keep form-property/vendors 'transition rejoin next collect [
                        foreach transition transitions [
                            keep ","
                            keep form-values transition
                        ]
                    ]
                ]
                keep "^/}"
            ]
        ]
        new: does [
            make self [
                values: copy []
                colors: copy []
                lengths: copy []
                transitions: copy []
                transformations: copy []
                spacing: copy []
            ]
        ]
    ]
    parser: context [
        google-fonts-base-url: http://fonts.googleapis.com/css?family=
        reset?: false
        rules: []
        google-fonts: []
        zero: use [zero] [
            [set zero integer! (zero: either zero? zero [[]] [[end skip]]) zero]
        ]
        em: ['em number! | zero]
        pt: ['pt number!]
        px: [opt 'px number!]
        deg: ['deg number! | zero]
        scalar: ['* number! | zero]
        percent: ['pct number! | zero]
        vh: ['vh number! | zero]
        vw: ['vw number! | zero]
        color: [tuple! | named-color]
        time: [time!]
        pair: [pair!]
        binary: [end skip]
        image: [binary | file! | url!]
        named-color: [
            'aqua | 'black | 'blue | 'fuchsia | 'gray | 'green |
            'lime | 'maroon | 'navy | 'olive | 'orange | 'purple |
            'red | 'silver | 'teal | 'white | 'yellow
        ]
        text-style: ['bold | 'italic | 'underline]
        border-style: ['solid | 'dotted | 'dashed]
        transition-attribute: [
            'width | 'height | 'top | 'bottom | 'right | 'left | 'z-index
            | 'background | 'color | 'border | 'opacity | 'margin
            | 'transform | 'font | 'indent | 'spacing
        ]
        direction: ['x | 'y | 'z]
        position-x: ['right | 'left | 'center]
        position-y: ['top | 'bottom | 'middle]
        position: [position-y | position-x]
        positions: [position-y position-x | position-y | position-x]
        repeats: ['repeat-x | 'repeat-y | 'repeat ['x | 'y] | 'no-repeat | 'no 'repeat]
        font-name: [string! | 'sans-serif | 'serif | 'monospace]
        length: [em | pt | px | percent | vh | vw]
        angle: [deg]
        number: [scalar | number!]
        box-model: ['block | 'inline 'block | 'inline-block]
        mark: capture: captured: none
        use [start extent] [
            mark: [start:]
            capture: [extent: (new-line/all captured: copy/part start extent false)]
        ]
        emit: func [name [word!] value [any-type!]] [
            value: compose [(value)]
            foreach [from to] [
                [no repeat] 'no-repeat
                [no bold] 'normal
                [no italic] 'normal
                [no underline] 'none
                [inline block] 'inline-block
                [line height] 'line-height
                [text indent] 'text-indent
            ] [
                replace value from to
            ]
            current/set name value
        ]
        emits: func [name [word!]] [
            emit name captured
        ]
        selector: use [
            dot-word primary qualifier
            form-element form-selectors
            out selectors selector
        ] [
            dot-word: use [word continue] [
                [
                    set word word!
                    (continue: either #"." = take form word [[]] [[end skip]])
                    continue
                ]
            ]
            primary: [tag! | issue! | dot-word]
            qualifier: [primary | get-word!]
            form-element: func [element [tag! issue! word! get-word!]] [
                either tag? element [to string! element] [mold element]
            ]
            form-selectors: func [selectors [block!]] [
                selectors: collect [
                    parse selectors [
                        some [mark some qualifier capture (keep/only captured)
                            | word! capture (keep captured)
                        ]
                    ]
                ]
                selectors: collect [
                    while [find selectors 'and] [
                        keep/only copy/part selectors selectors: find selectors 'and
                        selectors: next selectors
                    ] keep/only copy selectors
                ]
                selectors: map-each selector selectors [
                    collect [
                        foreach selector reverse collect [
                            while [find selector 'in] [
                                keep/only copy/part selector selector: find selector 'in
                                keep 'has
                                selector: next selector
                            ] keep/only copy selector
                        ] [keep selector]
                    ]
                ]
                selectors: collect [
                    foreach selector selectors [
                        parse selector [
                            set selector block! (selector: map-each element selector [form-element element])
                            any [
                                'with mark block! capture (
                                    selector: collect [
                                        foreach selector selector [
                                            foreach element captured/1 [
                                                keep join selector form-element element
                                            ]
                                        ]
                                    ]
                                ) |
                                'has mark block! capture (
                                    selector: collect [
                                        foreach selector selector [
                                            foreach element captured/1 [
                                                keep rejoin [selector " " form-element element]
                                            ]
                                        ]
                                    ]
                                )
                            ]
                        ]
                        keep/only selector
                    ]
                ]
                rejoin remove collect [
                    foreach selector selectors [
                        foreach rule selector [
                            keep "," keep "^/"
                            keep rule
                        ]
                    ]
                ]
            ]
            selector: [
                some primary any [
                    'with some qualifier
                    | 'in some primary
                    | 'and selector
                ]
            ]
            [
                mark
                some primary any [
                    'with some qualifier
                    | 'in some primary
                    | 'and selector
                ] capture
                (repend rules [form-selectors captured current: ruleset/new])
            ]
        ]
        property: [
            mark box-model capture (emits 'display)
            | mark 'border-box capture (emits 'box-sizing)
            | ['min 'height | 'min-height] mark length capture (emits 'min-height)
            | ['min 'width | 'min-width] mark length capture (emits 'min-width)
            | 'height mark length capture (emits 'height)
            | 'margin [
                mark [
                    1 2 [length opt [length | 'auto]]
                    | pair opt [length | pair]
                ] capture (emits 'margin)
                |
            ] any [
                'top mark length capture (emits 'margin-top)
                | 'bottom mark length capture (emits 'margin-bottom)
                | 'right mark [length | 'auto] capture (emits 'margin-right)
                | 'left mark [length | 'auto] capture (emits 'margin-left)
            ]
            | 'padding [
                mark [
                    1 4 length
                    | pair opt [length | pair]
                ] capture (emits 'padding)
                |
            ] any [
                'top mark length capture (emits 'padding-top)
                | 'bottom mark length capture (emits 'padding-bottom)
                | 'right mark [length | 'auto] capture (emits 'padding-right)
                | 'left mark [length | 'auto] capture (emits 'padding-left)
            ]
            | 'border any [
                mark 1 4 border-style capture (emits 'border-style)
                | mark 1 4 color capture (emits 'border-color)
                | 'radius [
                    some [
                        'top mark 1 2 length capture (
                            emits 'border-top-left-radius
                            emits 'border-top-right-radius
                        )
                        | 'bottom mark 1 2 length capture (
                            emits 'border-bottom-left-radius
                            emits 'border-bottom-right-radius
                        )
                        | 'right mark 1 2 length capture (
                            emits 'border-top-right-radius
                            emits 'border-bottom-right-radius
                        )
                        | 'left mark 1 2 length capture (
                            emits 'border-top-left-radius
                            emits 'border-bottom-left-radius
                        )
                        | 'top 'right mark 1 2 length capture (emits 'border-top-right-radius)
                        | 'top 'left mark 1 2 length capture (emits 'border-top-left-radius)
                        | 'bottom 'right mark 1 2 length capture (emits 'border-bottom-right-radius)
                        | 'bottom 'left mark 1 2 length capture (emits 'border-bottom-left-radius)
                    ]
                    | mark 1 2 length capture (emits 'border-radius)
                ]
                | mark 1 4 length capture (emits 'border-width)
            ]
            | ['radius | 'rounded] mark length capture (emits 'border-radius)
            | 'rounded (emit 'border-radius [em 0.6])
            | 'font any [
                mark length capture (emits 'font-size)
                | mark some font-name capture (
                    captured
                    remove head forskip captured 2 [insert captured '|]
                    emits 'font-family
                )
                | mark color capture (emits 'color)
                | 'line 'height mark number capture (emits 'line-height)
                | 'spacing mark number capture (emits 'letter-spacing)
                | 'shadow mark pair length color capture (emits 'text-shadow)
                | mark opt 'no 'bold capture (emits 'font-weight)
                | mark opt 'no 'italic capture (emits 'font-style)
                | mark opt 'no 'underline capture (emits 'text-decoration)
                | ['line-through | 'strike 'through] (emit 'text-decoration 'line-through)
            ]
            | 'text 'indent mark length capture (emits 'text-indent)
            | 'line 'height mark [length | scalar] capture (emits 'line-height)
            | 'spacing mark number capture (emits 'letter-spacing)
            | mark opt 'no 'bold capture (emits 'font-weight)
            | mark opt 'no 'italic capture (emits 'font-style)
            | mark opt 'no 'underline capture (emits 'text-decoration)
            | ['line-through | 'strike 'through] (emit 'text-decoration 'line-through)
            | 'shadow mark pair length color capture (emits 'box-shadow)
            | 'color mark [color | 'inherit] capture (emits 'color)
            | mark ['relative | 'absolute | 'fixed] capture (emits 'position) any [
                'top mark length capture (emits 'top)
                | 'bottom mark length capture (emits 'bottom)
                | 'right mark length capture (emits 'right)
                | 'left mark length capture (emits 'left)
            ]
            | 'opacity mark number capture (emits 'opacity)
            | mark 'nowrap capture (emits 'white-space)
            | mark 'center capture (emits 'text-align)
            | 'transition any [
                mark transition-attribute time opt time capture (
                    append/only current/transitions captured
                )
            ]
            | [
                'delay mark time capture (emits 'transition-delay)
                | mark time opt time transition-attribute capture (
                    append/only current/transitions head reverse next reverse captured
                )
                | mark time capture (emits 'transition)
            ]
            | some [
                mark [
                    'translate direction length
                    | 'rotate angle opt ['origin percent percent]
                    | 'scale [['x | 'y] number | 1 2 number]
                ] capture (append/only current/transformations captured)
            ]
            | mark 'preserve-3d capture (emits 'transform-style)
            | 'hide (emit 'display none)
            | 'float mark position-x capture (emits 'float)
            | 'opaque (emit 'opacity 1)
            | mark 'pointer capture (emits 'cursor)
            | ['canvas | 'background] any [
                mark color capture (emits 'background-color)
                | mark [file! | url!] (emits 'background-image)
                | mark positions capture (emits 'background-position)
                | mark repeats capture (emits 'background-repeat)
                | mark ['contain | 'cover] capture (emits 'background-size)
                | mark pair capture (
                    captured: first captured
                    emit 'background-position reduce [
                        'pct to integer! captured/x
                        'pct to integer! captured/y
                    ]
                )
            ]
            | mark [
                'radial color color capture (
                    insert at captured 3 '|
                )
                | 'linear angle color color capture (
                    insert at tail captured -2 '|
                    insert at tail captured -1 '|
                )
                | 'linear opt 'to positions color color capture (
                    unless 'to = captured/2 [insert next captured 'to]
                    insert at tail captured -2 '|
                    insert at tail captured -1 '|
                )
            ] (emits 'background-image)
            | mark image capture (emits 'background-image) any [
                mark positions capture (emits 'background-position)
                | mark pair capture (
                    captured: first captured
                    emit 'background-position reduce [
                        'pct to integer! captured/x
                        'pct to integer! captured/y
                    ]
                )
                | mark repeats capture (emits 'background-repeat)
                | mark ['contain | 'cover] capture (emits 'background-size)
            ]
            | mark [
                length capture (append/only current/lengths captured)
                | some color capture (append current/colors captured)
                | time capture (emits 'transition)
                | pair capture (
                    emit 'width captured/1/x
                    emit 'height captured/1/y
                )
            ]
        ]
        current: value: none
        errors: copy []
        dialect: [()
            opt ['css/reset (reset?: true)]
            opt [
                'google 'fonts [
                    some [
                        copy value [string! any issue!]
                        (append/only google-fonts value)
                        |
                        set value url! (
                            all [
                                value: find/match value google-fonts-base-url
                                append google-fonts value
                            ]
                        )
                    ]
                ]
            ]
            [selector | (repend rules [["body"] current: ruleset/new])]
            any [
                selector | property
                | set value skip (append errors rejoin ["MISPLACED TOKEN: " mold value])
            ]
        ]
        reset: to string! decompress #{
789C8D53B16EDB30109DC3AF200C14690D2992DD26838C76EE906EDD8A0CA478
925853A44C520E9C34FFDE47C936DCA2450288E2917CBC7BF7EE582C7917E350
15454F07F28F246F6AD717E4755D44E74C28EA100A4F8162C119E77CBFBE29F9
2FBE2E57AB72B5BE4B5BF7BA261BA8E2D659E2EF87511A5D73E57AA1ED07B62C
18EB626F322E9D3A645CE97DC6C3206CC6C530188A1977F227D59875E3454F19
EB5619EFD6181F313E61DC62DC657C800FE3EAED6E7491B0F4C00AB891D2E35F
7B670F3D0CA5C03700ABDB8CD73A416BA780550416AA4164024EF738D616C0AD
5419DF81153ED10F190BBD308086E8F596A6D95980C328D30F3422D8EE85CF18
3646784104B291B0A152089C2AB874B0470CA333D6388F9846C8C4418E313AD0
28968D26A34212C1504B5665902B0A69126731449D5071162E36CE01173B12F0
1D7D32311434F051D7E98A085A4D37ED5E20194551681352BA92708735BA1D21
1AC77CF69EBC82384F6EA7B9F52EA5C87AB248CD0A94CB8D711811DB8F124402
8A355D0D63DF0B7FC858D4281B87BD058751690775C0C4F1677685DD56DB8A97
1B7635A036DAB6F3423A8F80B3DD381BF3A09FD044ABB27C77DCA9509E0EAD18
B1DE534A52985C18DDC29D14818CB6B4612FAC58F2AFDFBFDDDFA2B7C260C421
F7CE109F9A16E979D40181B8F4EE31900F1C12FFADD859A93F9439AAC5FE27D1
8542474D52C24712D5DCAB895FAA5F3A497CF38E74DB21B5553A993B643E0B50
201ECCF11D4DF72E9A7D9740931DFE05A8242153BA7C209568A68EDC9DCF76F3
56F254435E4A0A5F5F6F2E5627C7530B26DC5CA4BC76C68821BDF193752E608E
B75C9F8AFAC2D8DCDB5595F7EE296F5C3D865C5B9B88688B26FA110F037D5E4C
C5593CBC069B9DBD8EC3CBECF51BFC35DAD0E2817FE16F0BC29F8F4D5A6E4EAD
5B6E8E0D5D6E90EC6F2B11BC2A3F050000
}
        render: does [
            rejoin collect [
                keep "/* CSSR Output */^/"
                if all [
                    block? google-fonts
                    not empty? google-fonts
                ] [
                    keep "^/@import url ('"
                    keep mold join google-fonts-base-url collect [
                        repeat font length? google-fonts [
                            unless font = 1 [keep "|"]
                            case [
                                url? google-fonts/:font [
                                    keep google-fonts/:font
                                ]
                                block? google-fonts/:font [
                                    keep replace/all mold to url! take google-fonts/:font "%20" "+"
                                    repeat variant length? google-fonts/:font [
                                        keep back change to url! mold google-fonts/:font/:variant either variant = 1 [":"] [","]
                                    ]
                                ]
                            ]
                        ]
                    ]
                    keep "');^/"
                ]
                if reset? [
                    keep {
/** CSS Reset Begin */

}
                    keep reset
                    keep "/* CSS Reset End **/^/"
                ]
                keep {
/** CSSR Output Begin */

}
                foreach [selector rule] rules [
                    keep selector
                    keep " "
                    keep rule/render
                    keep "^/"
                ]
                keep {

/* CSSR Output End **/
}
            ]
        ]
        new: does [
            make parser [
                reset?: false
                google-fonts: copy []
                rules: copy []
                errors: copy []
                current: ruleset/new
                value: none
            ]
        ]
    ]
    ??: use [mark] [[mark: (probe new-line/all copy/part mark 8 false)]]
    to-css: func [dialect [file! url! string! block!] /local out] [
        case/all [
            file? dialect [dialect: load dialect]
            url? dialect [dialect: load dialect]
            string? dialect [dialect: load dialect]
            not block? dialect [make error! "No Dialect!"]
        ]
        out: parser/new
        if parse dialect out/dialect [
            out/render
        ]
    ]
]
xml?: true
start-para?: true
end-para?: true
buffer: make string! 1000
para?: false
set [open-para close-para] either para? [[<p> </p>]] [["" ""]]
print [open-para close-para]
value: copy ""
emit: func [data] [print "***wrong emit***" append buffer data]
close-tag: func [tag] [head insert copy tag #"/"]
start-para: does [
    if start-para? [
        start-para?: false
        end-para?: true
        emit open-para
    ]
]
entities: [
    #"<" (emit "&lt;")
    | #">" (emit "&gt;")
    | #"&" (emit "&amp;")
]
escape-set: charset "\`*_{}[]()#+-.!"
escapes: use [escape] [
    [
        #"\"
        (start-para)
        set escape escape-set
        (emit escape)
    ]
]
numbers: charset [#"0" - #"9"]
plus: #"+"
minus: #"-"
asterisk: #"*"
underscore: #"_"
hash: #"#"
dot: #"."
eq: #"="
lt: #"<"
gt: #">"
header-underscore: use [text tag] [
    [
        copy text to newline
        newline
        some [eq (tag: <h1>) | minus (tag: <h2>)]
        [newline | end]
        (
            end-para?: false
            start-para?: true
            emit ajoin [tag text close-tag tag]
        )
    ]
]
header-hash: use [value continue trailing mark tag] [
    [
        (
            continue: either/only start-para? [not space] [fail]
            mark: clear ""
        )
        continue
        copy mark some hash
        space
        (emit tag: to tag! compose [h (length? mark)])
        some [
            [
                (trailing: "")
                [[any space mark] | [opt [2 space (trailing: join newline newline)]]]
                [newline | end]
                (end-para?: false)
                (start-para?: true)
                (emit ajoin [close-tag tag trailing])
            ]
            break
            | set value skip (emit value)
        ]
    ]
]
header-rule: [
    header-underscore
    | header-hash
]
autolink-rule: use [address] [
    [
        lt
        copy address
        to gt skip
        (
            start-para
            emit ajoin [{<a href="} address {">} address </a>]
        )
    ]
]
link-rule: use [text address value title] [
    [
        #"["
        copy text
        to #"]" skip
        #"("
        (
            address: clear ""
            title: none
        )
        any [
            not [space | tab | #")"]
            set value skip
            (append address value)
        ]
        opt [
            some [space | tab]
            #"^""
            copy title to #"^""
            skip
        ]
        skip
        (
            start-para
            title: either title [ajoin [space {title="} title {"}]] [""]
            emit ajoin [{<a href="} address {"} title ">" text </a>]
        )
    ]
]
em-rule: use [mark text] [
    [
        copy mark ["**" | "__" | "*" | "_"]
        not space
        copy text
        to mark mark
        (
            start-para
            mark: either equal? length? mark 1 <em> <strong>
            emit ajoin [mark text close-tag mark]
        )
    ]
]
img-rule: use [text address] [
    [
        #"!"
        #"["
        copy text
        to #"]" skip
        #"("
        copy address
        to #")" skip
        (
            start-para
            emit ajoin [{<img src="} address {" alt="} text {"} either xml? " /" "" ">"]
        )
    ]
]
horizontal-mark: [minus | asterisk | underscore]
horizontal-rule: [
    horizontal-mark
    any space
    horizontal-mark
    any space
    horizontal-mark
    any [
        horizontal-mark
        | space
    ]
    (
        end-para?: false
        emit either xml? <hr /> <hr>
    )
]
unordered: [any space [asterisk | plus | minus] space]
ordered: [any space some numbers dot space]
list-rule: use [continue tag item] [
    [
        some [
            (
                continue: either start-para? [
                    [
                        ordered (item: ordered tag: <ol>)
                        | unordered (item: unordered tag: <ul>)
                    ]
                ] [
                    [fail]
                ]
            )
            continue
            (start-para?: end-para?: false)
            (emit ajoin [tag newline <li>])
            line-rules
            newline
            (emit ajoin [</li> newline])
            some [
                item
                (emit <li>)
                line-rules
                [newline | end]
                (emit ajoin [</li> newline])
            ]
            (emit close-tag tag)
        ]
    ]
]
blockquote-rule: use [continue] [
    [
        (
            continue: either/only start-para? [gt any space] [fail]
        )
        continue
        (emit ajoin [<blockquote> newline])
        line-rules
        [[newline (emit newline)] | end]
        any [
            [newline] (remove back tail buffer emit ajoin [close-para newline newline open-para])
            | [
                continue
                opt line-rules
                [newline (emit newline) | end]
            ]
        ]
        (end-para?: false)
        (emit ajoin [close-para newline </blockquote>])
    ]
]
inline-code-rule: use [code value] [
    [
        [
            "``"
            (start-para)
            (emit <code>)
            some [
                "``" (emit </code>) break
                | entities
                | set value skip (emit value)
            ]
        ]
        | [
            "`"
            (start-para)
            (emit <code>)
            some [
                "`" (emit </code>) break
                | entities
                | set value skip (emit value)
            ]
        ]
    ]
]
code-line: use [value] [
    [
        some [
            entities
            | [newline | end] (emit newline) break
            | set value skip (emit value)
        ]
    ]
]
code-rule: use [text] [
    [
        [4 space | tab]
        (emit ajoin [<pre> <code>])
        code-line
        any [
            [4 space | tab]
            code-line
        ]
        (emit ajoin [</code> </pre>])
        (end-para?: false)
    ]
]
asterisk-rule: ["\*" (emit "*")]
newline-rule: [
    newline
    any [space | tab]
    some newline
    any [space | tab]
    (
        emit ajoin [close-para newline newline]
        start-para?: true
    )
    | newline (emit newline)
]
line-break-rule: [
    space
    some space
    newline
    (emit ajoin [either xml? <br /> <br> newline])
]
leading-spaces: use [continue] [
    [
        (continue: either/only start-para? [some space] [fail])
        continue
        (start-para)
    ]
]
line-rules: [
    some [
        em-rule
        | link-rule
        | header-rule
        | not newline set value skip (
            start-para
            emit value
        )
    ]
]
rules: [
    some [
        header-rule
        | link-rule
        | autolink-rule
        | img-rule
        | list-rule
        | blockquote-rule
        | inline-code-rule
        | code-rule
        | asterisk-rule
        | em-rule
        | horizontal-rule
        | entities
        | escapes
        | line-break-rule
        | newline-rule
        | end (if end-para? [end-para?: false emit close-para])
        | leading-spaces
        | set value skip (
            start-para
            emit value
        )
    ]
]
markdown: func [
    "Parse markdown source to HTML or XHTML"
    data
    /only "Return result without newlines"
    /xml {Switch from HTML tags to XML tags (e.g.: <hr /> instead of <hr>)}
] [
    print "markdown"
    start-para?: true
    end-para?: true
    buffer: make string! 1000
    parse data [some rules]
    buffer
]
print "import"
load-web-color: func [
    "Convert hex RGB issue! value to tuple!"
    color [issue!]
    /local pos
] [
    to tuple! debase/base next form color 16
]
to-hsl: func [
    color [tuple!]
    /local min max delta alpha total
] [
    if color/4 [alpha: color/4 / 255]
    color: reduce [color/1 color/2 color/3]
    bind/new [r g b] local: object []
    set words-of local map-each c color [c / 255]
    color: local
    min: first minimum-of values-of color
    max: first maximum-of values-of color
    delta: max - min
    total: max + min
    local: object [h: s: l: to percent! total / 2]
    do in local bind [
        either zero? delta [h: s: 0] [
            s: to percent! either l > 0.5 [2 - max - min] [delta / total]
            h: 60 * switch max reduce [
                r [g - b / delta + either g < b 6 0]
                g [b - r / delta + 2]
                b [r - g / delta + 4]
            ]
        ]
    ] color
    local: values-of local
    if alpha [append local alpha]
    local
]
to-hsv: func [
    color [tuple!]
    /local min max delta alpha
] [
    if color/4 [alpha: color/4 / 255]
    color: reduce [color/1 color/2 color/3]
    bind/new [r g b] local: object []
    set words-of local map-each c color [c / 255]
    color: local
    min: first minimum-of values-of color
    max: first maximum-of values-of color
    delta: max - min
    local: object [h: s: v: to percent! max]
    do in local bind [
        either zero? delta [h: s: 0] [
            s: to percent! either delta = 0 [0] [delta / max]
            h: 60 * switch max reduce [
                r [g - b / delta + either g < b 6 0]
                g [b - r / delta + 2]
                b [r - g / delta + 4]
            ]
        ]
    ] color
    local: values-of local
    if alpha [append local alpha]
    local
]
load-hsl: func [
    color [block!]
    /local alpha c x m i
] [
    if color/4 [alpha: color/4]
    bind/new [h s l] local: object []
    set words-of local color
    bind/new [r g b] color: object []
    do in local [
        i: h / 60
        c: 1 - (abs 2 * l - 1) * s
        x: 1 - (abs -1 + mod i 2) * c
        m: l - (c / 2)
    ]
    do in color [
        set [r g b] reduce switch to integer! i [
            0 [[c x 0]]
            1 [[x c 0]]
            2 [[0 c x]]
            3 [[0 x c]]
            4 [[x 0 c]]
            5 [[c 0 x]]
        ]
    ]
    color: to tuple! map-each value values-of color [to integer! round m + value * 255]
    if alpha [color/4: alpha * 255]
    color
]
load-hsv: func [
    color [block!]
    /local alpha c x m i
] [
    if color/4 [alpha: color/4]
    bind/new [h s v] local: object []
    set words-of local color
    bind/new [r g b] color: object []
    do in local [
        i: h / 60
        c: v * s
        x: 1 - (abs -1 + mod i 2) * c
        m: v - c
    ]
    do in color [
        set [r g b] reduce switch to integer! i [
            0 [[c x 0]]
            1 [[x c 0]]
            2 [[0 c x]]
            3 [[0 x c]]
            4 [[x 0 c]]
            5 [[c 0 x]]
        ]
    ]
    color: to tuple! map-each value values-of color [to integer! round m + value * 255]
    if alpha [color/4: alpha * 255]
    color
]
color!: object [
    rgb: 0.0.0.0
    web: #000000
    hsl: make block! 4
    hsv: make block! 4
]
new-color: does [make color! []]
set-color: func [
    color [object!] "Color object"
    value [block! tuple! issue!]
    type [word!]
] [
    switch type [
        rgb [
            do in color [
                rgb: value
                web: to-hex value
                hsl: to-hsl value
                hsv: to-hsv value
            ]
        ]
        web [
            do in color [
                rgb: load-web-color value
                web: value
                hsl: to-hsl rgb
                hsv: to-hsv rgb
            ]
        ]
        hsl [
            do in color [
                rgb: load-hsl value
                web: to-hex rgb
                hsl: value
                hsv: to-hsv load-hsv value
            ]
        ]
        hsv [
            do in color [
                rgb: load-hsv value
                web: to-hex rgb
                hsl: to-hsl load-hsv value
                hsv: value
            ]
        ]
    ]
    color
]
apply-color: func [
    "Apply color effect on color"
    color [object!] "Color! object"
    effect [word!] "Effect to apply"
    amount [number!] "Effect amount"
] [
    effect: do bind select effects effect 'amount
    set-color color color/:effect effect
]
effects: [
    darken [
        color/hsl/3: max 000% color/hsl/3 - amount
        'hsl
    ]
    lighten [
        color/hsl/3: min 100% color/hsl/3 + amount
        'hsl
    ]
    saturate [
        color/hsl/2: min 100% max 000% color/hsl/2 + amount
        'hsl
    ]
    desaturate [
        color/hsl/2: min 100% max 000% color/hsl/2 - amount
        'hsl
    ]
    hue [
        color/hsl/1: color/hsl/1 + amount // 360
        'hsl
    ]
]
load-color: func [
    "Convert hex RGB issue! value to tuple!"
    color [issue!]
    /local pos
] [
    to tuple! debase/base next form color 16
]
rule: func [
    "Make PARSE rule with local variables"
    local [word! block!] "Local variable(s)"
    rule [block!] "PARSE rule"
] [
    use local reduce [rule]
]
recat: func [
    {Something like COMBINE but with much cooler name, just to piss off @HostileFork.}
    block [block!]
    /with "Add delimiter between values"
    delimiter
    /trim "Remove NONE values"
    /only "Do not reduce, but that makes no sense"
] [
    block: either only [block] [reduce block]
    if empty? block [return block]
    if trim [block: lib/trim block]
    if with [
        with: make block! 2 * length? block
        foreach value block [repend with [value delimiter]]
        block: head remove back tail with
    ]
    append either string? first block [
        make string! length? block
    ] [
        make block! length? block
    ] block
]
buffer: make string! 0
emit: func [data] [
    switch type?/word data [
        issue! [data: load-color data]
    ]
    append buffer data
]
color-funcs: [
    darken [100% - amount * color]
    lighten [white - color * amount + color]
    saturate [
        color: rgb-hsv color
        color/2: min 1.0 max 0.0 color/2 + amount
        hsv-rgb color
    ]
    desaturate [
        color: rgb-hsv color
        color/2: min 1.0 max 0.0 color/2 - amount
        hsv-rgb color
    ]
    spin [
        color: rgb-hsv color
        color/1: color/1 + amount
        hsv-rgb color
    ]
]
get-color: func [color] [
    case/all [
        word? color [color: user-ctx/:color]
        issue? color [color: load-color color]
        true [color]
    ]
]
user-ctx: object []
ruleset: object [
    user: [fail]
    assign: rule [name value] [
        set name set-word!
        opt functions
        set value any-type! (
            if word? value [value: get in user-ctx value]
            repend user-ctx [name value]
            append user compose [
                |
                pos: (to lit-word! name)
                (
                    to paren! compose [
                        change/part pos (to path! reduce ['user-ctx to word! name]) 1
                    ]
                )
                :pos some rules
            ]
        )
    ]
    functions: rule [f f-stack color amount pos] [
        (f-stack: [])
        set f ['darken | 'lighten | 'saturate | 'desaturate | 'hue]
        (append f-stack f)
        opt functions
        set color match-color
        pos:
        set amount number! (
            f: take/last f-stack
            print ["color: " type? color mold color mold user-ctx/:color]
            case/all [
                word? color [color: user-ctx/:color]
                issue? color [color: load-color color]
                tuple? color [color: set-color new-color color 'rgb]
                true [color: apply-color color f amount]
            ]
            change pos color/rgb
        )
        :pos
    ]
    em: rule [value] [
        'em set value number!
        (emit compose [em (value)])
    ]
    canvas: rule [value] [
        'canvas
        set value match-color
        (emit compose [canvas (get-color value)])
    ]
    tags: use [data tag-list tag] [
        data: load decompress debase {eJxFUltWQyEM/HcVbsHnV497CRd6i+VlCNXuXmZo
^-^-^-9YOZIYQkhBzk4+EgzinIew29Q2mgXS1uKUD16MnDxzrZYUmHyflIpDnV7fw1qvGg+i
^-^-^-sIod0wq2WKTcpFOkWzuEyR7lv1i9LCXetolDlL8VN5MUmxGyT3IRFNYkJIf0Q4H5V4
^-^-^-AdIBF0ImuICLxxiS78Eo9/9K5mYoijjW+QSlUFw8PX08TnwmvhBfiW/Ed7gE8Tfizd
^-^-^-O9/hN3llEKOhWPKhlJYt6BpQ0jzyc8HM4OUc7hugdUlMTxkSnMPU5SJJTzpCyNqNyE
^-^-^-Mkgmi1hFEbSh1L5pbEhT3WfYKBC2NruXWe9NqMNWRbA2mcWC2Zamdb9NyNdcCg+Fqw
^-^-^-6Hr8ZBlwzzX8I+063APaSVumdJyN7r0A1xexM6mNayU1w5dX044hwAZXxWauJ4arcB
^-^-^-M/TFwo/dptbwe+ATYf2LRfbcoq27SpANrUPfBgq6CMyXOeoV//qN0f0F7xf7rSEDAAA=}
        tag-list: make block! 2 * length? data
        foreach value data [repend tag-list [to lit-word! to string! value '|]]
        take/last tag-list
        [
            set tag tag-list
            (emit to tag! tag)
        ]
    ]
    google-fonts: rule [value values] [
        'google 'fonts
        (values: make block! 10)
        some [
            set value [string! | issue!]
            (append values value)
        ]
        (emit compose [google fonts (values)])
    ]
    pass: rule [value] [
        set value skip
        (emit value)
    ]
    match-color: rule [user-words] [
        (
            user-words: make block! 2 * length? user-ctx
            foreach word words-of user-ctx [
                repend user-words [to lit-word! word '|]
            ]
            take/last user-words
        )
        [issue! | tuple! | user-words]
    ]
]
rules: none
init: does [
    buffer: make block! 1000
    append clear ruleset/user 'fail
    rules: recat/with words-of ruleset '|
]
precssr: func [
    data
] [
    init
    parse data [some rules]
    buffer
]
print "import done"
debug:
:print
none
js-path: %../../js/
css-path: %../../css/
js-path: %js/
css-path: %css/
plugin-path: %/home/sony/repo/lest/plugins/
text-style: 'html
dot: #"."
escape-entities: funct [
    "Escape HTML entities. Only partial support now."
    data
] [
    output: make string! 1.1 * length? data
    entities: [
        #"<" "lt"
        #">" "gt"
        #"&" "amp"
    ]
    rule: make block! length? entities
    forskip entities 2 [
        repend rule [
            entities/1
            to paren! reduce ['append 'output rejoin [#"&" entities/2 #";"]]
            '|
        ]
    ]
    append rule [set value skip (append output value)]
    parse data [some rule]
    output
]
catenate: funct [
    "Joins values with delimiter."
    src [block!]
    delimiter [char! string!]
    /as-is "Mold values"
] [
    out: make string! 200
    forall src [repend out [either as-is [mold src/1] [src/1] delimiter]]
    len: either char? delimiter [1] [length? delimiter]
    head remove/part skip tail out negate len len
]
replace-deep: funct [
    target
    'search
    'replace
] [
    rule: compose [
        change (:search) (:replace)
        | any-string!
        | into [some rule]
        | skip
    ]
    parse target [some rule]
    target
]
rule: func [
    "Make PARSE rule with local variables"
    local [word! block!] "Local variable(s)"
    rule [block!] "PARSE rule"
] [
    if word? local [local: reduce [local]]
    use local reduce [rule]
]
add-rule: func [
    "Add new rule to PARSE rules block!"
    rules [block!]
    rule [block!]
] [
    unless empty? rules [
        append rules '|
    ]
    append/only rules rule
]
to-www-form: func [
    {Convert object body (block!) to application/x-www-form-urlencoded}
    data
    /local out
] [
    out: copy ""
    foreach [key value] data [
        if issue? value [value: next value]
        repend out [
            to word! key
            #"="
            value
            #"&"
        ]
    ]
    head remove back tail out
]
build-tag: funct [
    name [word!]
    values [block! object! map!]
] [
    tag: make string! 256
    repend tag [#"<" name space]
    unless block? values [values: body-of values]
    foreach [name value] values [
        skip?: false
        value: switch/default type?/word value [
            block! [
                if empty? value [skip?: true]
                catenate value #" "
            ]
            string! [if empty? value [skip?: true] value]
            none! [skip?: true]
        ] [
            form value
        ]
        unless skip? [
            repend tag [to word! name {="} value {" }]
        ]
    ]
    head change back tail tag #">"
]
entag: func [
    "Enclose value in tag"
    data
    tag
    /with
    values
] [
    unless with [values: clear []]
    ajoin [
        build-tag tag values
        reduce data
        close-tag tag
    ]
]
close-tag: func [
    type
] [
    ajoin ["</" type ">"]
]
lest: use [
    output
    buffer
    page
    tag
    tag-name
    tag-stack
    includes
    rules
    header?
    pos
    current-text-style
    name
    value
    emit
    emit-label
    emit-stylesheet
    user-rules
    user-words
    user-values
    plugins
    load-plugin
] [
    output: copy ""
    buffer: copy ""
    header?: false
    tag-stack: copy []
    includes: object [
        style: make block! 1000
        stylesheets: copy ""
        header: copy ""
        body-start: copy ""
        body-end: copy ""
    ]
    emit: func [
        data [string! block! tag!]
    ] [
        if block? data [data: ajoin data]
        if tag? data [data: mold data]
        append buffer data
    ]
    emit-label: func [
        label
        elem
        /class
        styles
    ] [
        emit entag/with label 'label reduce/no-set [for: elem class: styles]
    ]
    emit-script: func [
        script
        /insert
        /append
    ] [
        if insert [lib/append includes/body-start script]
        if append [lib/append includes/body-end script]
    ]
    emit-stylesheet: func [
        stylesheet
        /local suffix
    ] [
        local: stylesheet
        if all [
            file? stylesheet
            not equal? %.css suffix: suffix? stylesheet
        ] [
            write
            local: replace copy stylesheet suffix %.css
            to-css precssr load stylesheet
        ]
        unless find includes/stylesheets stylesheet [
            repend includes/stylesheets [{<link href="} local {" rel="stylesheet">} newline]
        ]
    ]
    rules: object [
        tag: tag
        tag-name: tag-name
        value-to-emit: none
        emit-value: [
            (emit value-to-emit)
        ]
        import: rule [p value] [
            'import p: set value [file! | url!]
            (p/1: load value)
            :p into elements
        ]
        text-settings: rule [type] [
            set type ['plain | 'html | 'markdown]
            'text
            (text-style: type)
        ]
        settings-rule: [
            text-settings
        ]
        do-code: rule [p value] [
            p: set value paren!
            (p/1: append clear [] do bind to block! value user-words)
            :p into elements
        ]
        set-rule: rule [label value] [
            'set
            set label word!
            set value any-type!
            (
                value: switch/default value [
                    true yes on [lib/true]
                    false no off [lib/false]
                ] [value]
                unless in user-words label [
                    append user-values compose [
                        |
                        pos: (to lit-word! label)
                        (to paren! compose [change pos (to path! reduce ['user-words label])])
                        :pos
                    ]
                ]
                repend user-words [to set-word! label value]
            )
        ]
        user-rule: rule [name label type value urule args] [
            set name set-word!
            (
                args: copy []
                add-rule user-rules reduce [
                    to set-word! 'pos
                    to lit-word! name
                ]
            )
            any [
                set label word!
                set type word!
                (
                    add-rule args rule [px] reduce [
                        to set-word! 'px to lit-word! label
                        to paren! reduce/no-set [to set-path! 'px/1 label]
                    ]
                    repend last user-rules [to set-word! 'pos 'set label type]
                )
            ]
            set value block!
            (
                append last user-rules reduce [
                    to paren! compose/only [
                        urule: (compose [
                                any-string!
                                | into [some urule]
                                | (args)
                                | skip
                            ])
                        parse temp: copy/deep (value) [some urule]
                        change/only pos temp
                    ]
                    to get-word! 'pos 'into main-rule
                ]
            )
        ]
        style-rule: rule [data] [
            'style
            set data block!
            (append includes/style data)
        ]
        make-row: [
            'row
            'with
            (
                index: 1
                offset: none
            )
            some [
                set cols integer!
                ['col | 'cols]
                | 'offset
                set offset integer!
            ]
            set element block!
            'replace
            set value tag!
            [
                'from
                set data pos: [block! | word! | file! | url!]
                (
                    out: make block! length? data
                    switch type?/word data [
                        word! [data: get data]
                        url! [data: read data]
                        file! [data: load data]
                    ]
                    foreach item data [
                        current: copy/deep element
                        replace-deep current value item
                        if offset [
                            insert skip find current 'col 2 reduce ['offset offset]
                            offset: none
                        ]
                        append out current
                    ]
                    change/only pos compose/deep [row [(out)]]
                )
                :pos into main-rule
                | 'with
                pos: set data block!
                (
                    out: make block! length? data
                    repeat index cols [
                        current: copy/deep element
                        replace-deep current value do bind data 'index
                        if offset [
                            insert skip find current 'col 2 reduce ['offset offset]
                            offset: none
                        ]
                        append out current
                    ]
                    change/only pos compose/deep [row [(out)]]
                )
                :pos into main-rule
            ]
        ]
        for-rule: rule [pos out var src content] [
            'for
            set var [word! | block!]
            'in
            set src [word! | block!]
            pos: set content block! (
                out: make block! length? src
                if word? src [src: get in user-words src]
                forall src [
                    either block? var [
                        repeat i length? var [
                            append out compose/only [set (var/:i) (src/:i)]
                        ]
                        src: skip src -1 + length? var
                        append/only out copy/deep content
                    ] [
                        append out compose/only [set (var) (src/1) (copy/deep content)]
                    ]
                ]
                change/only/part pos out 1
            )
            :pos into main-rule
        ]
        repeat-rule: [
            'repeat
            (offset: none)
            opt [
                'offset
                set offset integer!
            ]
            set element block!
            'replace
            set value tag!
            [
                [
                    'from
                    set data [block! | word!]
                    (
                        if word? data [data: get data]
                        out: make block! length? data
                        foreach item data [
                            current: copy/deep element
                            replace-deep current value item
                            if offset [
                                insert skip find current 'col 2 reduce ['offset offset]
                                offset: none
                            ]
                            append out current
                        ]
                        emit lest compose/deep [row [(out)]]
                    )
                ]
                | [
                    'with
                    set data block!
                    ()
                ]
            ]
        ]
        init-tag: [
            (
                insert tag-stack reduce [tag-name tag: context [id: none class: copy []]]
            )
        ]
        take-tag: [(set [tag-name tag] take/part tag-stack 2)]
        emit-tag: [(emit build-tag tag-name tag)]
        end-tag: [
            take-tag
            (emit close-tag tag-name)
        ]
        init-div: [
            (tag-name: 'div)
            init-tag
        ]
        close-div: [
            (
                tag: take/part tag-stack 2
                emit </div>
            )
        ]
        commands: [
            if-rule
            | either-rule
            | switch-rule
        ]
        if-rule: rule [cond true-val] [
            'if
            set cond [logic! | word! | block!]
            pos:
            set true-val any-type!
            (
                res: if/only do bind cond user-words true-val
                either res [
                    change/part pos res 1
                ] [
                    pos: next pos
                ]
            )
            :pos
        ]
        either-rule: rule [cond true-val false-val pos] [
            'either
            set cond [logic! | word! | block!]
            set true-val any-type!
            pos:
            set false-val any-type!
            (
                change/part
                pos
                either/only do bind cond user-words true-val false-val
                1
            )
            :pos
        ]
        switch-rule: rule [value cases defval] [
            'switch
            (defval: none)
            set value word!
            pos:
            set cases block!
            opt [
                'default
                pos:
                set defval any-type!
            ]
            (
                forskip cases 2 [cases/2: append/only copy [] cases/2]
                value: get bind value user-words
                change/part
                pos
                switch/default value cases append/only copy [] defval
                1
            )
            :pos
        ]
        get-style: rule [pos data type] [
            set type ['id | 'class]
            pos:
            set data [word! | block!] (
                data: either word? data [get bind data user-words] [rejoin bind data user-words]
                data: either type = 'id [to issue! data] [to word! head insert to string! data dot]
                change/part pos data 1
            )
            :pos
        ]
        style: rule [pos word continue] [
            any [
                commands
                | get-style
                | set word issue! (tag/id: next form word)
                | [
                    pos: set word word!
                    (
                        continue: either #"." = take form word [
                            append tag/class next form word
                            []
                        ] [
                            [end skip]
                        ]
                    )
                    continue
                ]
                | 'with set word block! (append tag word)
            ]
        ]
        comment: [
            'comment [block! | string!]
        ]
        debug-rule: rule [value] [
            'debug set value string!
            (print ["DEBUG:" value])
        ]
        script: rule [type value] [
            opt [set type ['insert | 'append]]
            'script
            init-tag
            set value [string! | file! | url! | path!]
            (
                if path? value [
                    value: get first bind reduce [value] user-words
                ]
                value: ajoin either string? value [
                    [<script type="text/javascript"> value]
                ] [
                    [{<script src="} value {">}]
                ]
                append value close-tag 'script
                switch/default type [
                    insert [emit-script/insert value]
                    append [emit-script/append value]
                ] [emit value]
            )
        ]
        stylesheet: rule [value] [
            pos:
            'stylesheet set value [file! | url! | path!] (
                if path? value [
                    value: get first bind reduce [value] user-words
                ]
                emit-stylesheet value
                debug ["==STYLESHEET:" value]
            )
        ]
        page-header: [
            'head (debug "==HEAD")
            (header?: true)
            header-content
            'body (debug "==BODY")
        ]
        header-content: rule [name value] [
            any [
                'title set value string! (page/title: value debug "==TITLE")
                | set-rule
                | stylesheet
                | style-rule
                | 'style set value string! (
                    append includes/stylesheet entag value 'style
                )
                | 'script [
                    set value [file! | url!] (
                        repend includes/header [{<script src="} value {">} </script> newline]
                    )
                    | set value string! (
                        append includes/header entag value 'script
                    )
                ]
                | 'meta set name word! set value string! (
                    repend page/meta [{<meta name="} name {" content="} value {">}]
                )
                | 'favicon set value url! (
                    repend includes/header [
                        {<link rel="icon" type="image/png" href="} value {">}
                    ]
                )
                | plugins
            ]
        ]
        br: ['br (emit <br>)]
        hr: ['hr (emit <hr>)]
        main-rule: [
            some match-content
        ]
        match-content: [
            commands
            | basic-string
            | elements
            | into main-rule
        ]
        paired-tags: ['i | 'b | 'p | 'pre | 'code | 'div | 'span | 'small | 'em | 'strong | 'footer | 'nav | 'section | 'button]
        paired-tag: [
            set tag-name paired-tags
            init-tag
            opt style
            emit-tag
            match-content
            end-tag
        ]
        image: rule [value] [
            ['img | 'image]
            (
                debug "==IMAGE"
                tag-name: 'img
            )
            init-tag
            some [
                set value [file! | url!] (
                    append tag compose [src: (value)]
                )
                | set value pair! (
                    append tag compose [
                        width: (to integer! value/x)
                        height: (to integer! value/y)
                    ]
                )
                | style
            ]
            take-tag
            emit-tag
        ]
        link: rule [value] [
            ['a | 'link] (tag-name: 'a)
            init-tag
            set value [file! | url! | issue!]
            (append tag compose [href: (value)])
            opt style
            emit-tag
            match-content
            end-tag
        ]
        li: [
            set tag-name 'li
            init-tag
            opt style
            emit-tag
            match-content
            end-tag
        ]
        ul: [
            set tag-name 'ul
            (debug "--UL--")
            init-tag
            opt style
            emit-tag
            some li
            end-tag
        ]
        ol: rule [value] [
            set tag-name 'ol
            init-tag
            any [
                set value integer! (append tag compose [start: (value)])
                | style
            ]
            emit-tag
            some li
            end-tag
        ]
        dl: [
            set tag-name 'dl
            init-tag
            opt [
                'horizontal (append tag/class 'dl-horizontal)
                | style
            ]
            emit-tag
            some [
                basic-string-match
                basic-string-processing
                (emit entag value 'dt)
                basic-string-match
                basic-string-processing
                (emit entag value 'dd)
            ]
            end-tag
        ]
        list-elems: [
            ul
            | ol
            | dl
        ]
        basic-elems: [
            basic-string
            | comment
            | debug-rule
            | stop
            | br
            | hr
            | table
            | paired-tag
            | image
            | link
            | list-elems
        ]
        basic-string-match: [
            (current-text-style: none)
            opt [set current-text-style ['plain | 'html | 'markdown]]
            opt [user-values]
            copy value [string! | date! | time!]
        ]
        basic-string-processing: [
            (
                unless current-text-style [current-text-style: text-style]
                value: form value
                value: switch current-text-style [
                    plain [value]
                    html [escape-entities value]
                    markdown [markdown value]
                ]
            )
        ]
        basic-string: rule [value style] [
            (style: none)
            opt [set style ['plain | 'html | 'markdown]]
            opt [user-values]
            set value [string! | date! | time!]
            (
                unless style [style: text-style]
                value: form value
                emit switch style [
                    plain [value]
                    html [escape-entities value]
                    markdown [markdown value]
                ]
            )
        ]
        stop: [
            'stop
            to end
        ]
        heading: [
            set tag-name ['h1 | 'h2 | 'h3 | 'h4 | 'h5 | 'h6]
            init-tag
            opt style
            emit-tag
            match-content
            end-tag
        ]
        table: rule [value] [
            set tag-name 'table
            init-tag
            style
            (insert tag/class 'table)
            emit-tag
            opt [
                'header
                (emit <tr>)
                into [
                    some [
                        set value string!
                        (emit ajoin [<th> value </th>])
                    ]
                ]
                (emit </tr>)
            ]
            some [
                into [
                    (emit <tr>)
                    some [
                        (pos: tail buffer)
                        basic-elems
                        (insert pos <td>)
                        (emit </td>)
                    ]
                    (emit </tr>)
                ]
            ]
            end-tag
        ]
        init-input: rule [value] [
            (
                tag-name: 'input
                default: none
            )
            init-tag
            (
                tag-name: first tag-stack
                tag: second tag-stack
            )
        ]
        emit-input: [
            (
                switch/default form-type [
                    horizontal [
                        unless empty? label [
                            emit-label/class label name [col-sm-2 control-label]
                        ]
                        emit <div class="col-sm-10">
                        set [tag-name tag] take/part tag-stack 2
                        append tag compose [name: (name) placeholder: (default) value: (value)]
                        emit build-tag tag-name tag
                        emit </div>
                    ]
                ] [
                    unless empty? label [
                        emit-label label name
                    ]
                    set [tag-name tag] take/part tag-stack 2
                    append tag compose [name: (name) placeholder: (default) value: (value)]
                    emit build-tag tag-name tag
                ]
            )
        ]
        input-parameters: [
            set name word!
            some [
                set label string!
                | 'default set default string!
                | 'value set value string!
                | style
            ]
        ]
        input: rule [type] [
            set type [
                'text | 'password | 'datetime | 'datetime-local | 'date | 'month | 'time | 'week
                | 'number | 'email | 'url | 'search | 'tel | 'color
            ]
            (emit <div class="form-group">)
            init-input
            (append tag/class 'form-control)
            (append tag reduce/no-set [type: type])
            input-parameters
            emit-input
            (emit </div>)
        ]
        checkbox: rule [type] [
            set type 'checkbox
            (emit ["" <div class="checkbox"> <label>])
            init-input
            input-parameters
            take-tag
            (
                append tag compose [type: (type) name: (name)]
                emit [build-tag tag-name tag label </label> </div>]
            )
        ]
        radio: rule [type] [
            set type 'radio
            (
                debug "==RADIO"
                emit ["" <div class="radio">]
                special: copy []
            )
            init-input
            set name word!
            set value [word! | string! | number!]
            some [
                set label string!
                | 'checked (append special 'checked)
                | style
            ]
            take-tag
            (
                append tag compose [type: (type) name: (name) value: (value)]
                emit [
                    make-tag/special tag special
                    {<label for="} tag/id {">} label
                    </label>
                    </div>
                ]
            )
        ]
        textarea: [
            set tag-name 'textarea
            (
                size: 50x4
                label: ""
            )
            init-tag
            set name word!
            (
                value: ""
                default: ""
            )
            some [
                set size pair!
                | set label string!
                | 'default set default string!
                | 'value set value string!
                | style
            ]
            take-tag
            (
                unless empty? label [emit-label label name]
                append tag compose [
                    cols: (to integer! size/x)
                    rows: (to integer! size/y)
                    name: (name)
                ]
                emit entag/with value tag-name tag
            )
        ]
        hidden: rule [name value] [
            'hidden
            init-input
            set name word!
            some [
                set value string!
                | style
            ]
            take-tag
            (append tag compose [type: 'hidden name: (name) value: (value)])
            emit-tag
        ]
        submit: rule [label] [
            'submit
            (
                insert tag-stack reduce [
                    'button
                    context [
                        type: 'submit
                        id: none
                        class: copy [btn btn-default]
                    ]
                ]
            )
            some [
                set label string!
                | style
            ]
            take-tag
            (
                switch/default form-type [
                    horizontal [
                        emit [
                            <div class="form-group">
                            <div class="col-sm-offset-2 col-sm-10">
                            build-tag tag-name tag
                            label
                            </button>
                            </div>
                            </div>
                        ]
                    ]
                ] [
                    emit [build-tag tag-name tag label </button>]
                ]
            )
        ]
        form-content: [
            [
                br
                | input
                | textarea
                | checkbox
                | radio
                | submit
                | hidden
            ]
        ]
        form-type: none
        form-rule: rule [value form-type] [
            set tag-name 'form
            (form-type: none)
            init-tag
            opt [
                'horizontal
                (form-type: 'horizontal)
            ]
            (
                append tag compose [
                    action: (value)
                    method: 'post
                    role: 'form
                ]
                if form-type [append tag/class join "form-" form-type]
            )
            some [
                set value [file! | url!] (
                    append tag compose [action: (value)]
                )
                | style
            ]
            take-tag
            emit-tag
            into main-rule
            (emit close-tag 'form)
        ]
        elements: rule [] [
            pos: (debug ["parse at: " index? pos "::" trim/lines copy/part mold pos 24])
            [
                settings-rule
                | page-header
                | basic-elems
                | form-content
                | import
                | do-code
                | for-rule
                | repeat-rule
                | make-row
                | user-rules
                | user-rule
                | set-rule
                | heading
                | form-rule
                | script
                | stylesheet
                | plugins
            ]
            (
                value: none
            )
        ]
        plugins: rule [name t] [
            'enable pos: set name word! (
                either t: load-plugin name [change/part pos t 1] [pos: next pos]
            )
            :pos [main-rule | into main-rule]
        ]
    ]
    load-plugin: func [
        name
        /local plugin header
    ] [
        debug ["load plugin" name]
        either value? 'plugin-cache [
            plugin: select plugin-cache name
            header: object [type: 'lest-plugin]
        ] [
            plugin: load/header rejoin [plugin-path name %.reb]
            header: take plugin
        ]
        plugin: object bind plugin rules
        if equal? 'lest-plugin header/type [
            if in plugin 'rule [add-rule rules/plugins bind plugin/rule 'emit]
            if in plugin 'startup [return plugin/startup]
        ]
        none
    ]
    user-rules: rule [] [fail]
    user-words: object []
    user-values: [fail]
    func [
        "Parse simple HTML dialect"
        data [block! file! url!]
    ] bind [
        if any [file? data url? data] [data: load data]
        tag-stack: copy []
        user-rules: copy [fail]
        user-words: object []
        user-values: copy [fail]
        output: copy ""
        buffer: copy ""
        includes: object [
            style: make block! 1000
            stylesheets: copy ""
            header: copy ""
            body-start: copy ""
            body-end: copy ""
        ]
        page: reduce/no-set [
            title: "Page generated with Bootrapy"
            meta: copy ""
            lang: "en-US"
        ]
        header?: false
        make-tag: funct [
            tag [object!]
            /special "Special attributes (without value):"
            attributes [block!]
        ] [
            out: make string! 256
            skip?: false
            repend out ["<" tag/element]
            tag: head remove/part find body-of tag to set-word! 'element 2
            foreach [key value] tag [
                skip?: false
                value: switch/default type?/word value [
                    block! [
                        if empty? value [skip?: true]
                        catenate value #" "
                    ]
                    string! [if empty? value [skip?: true] value]
                    none! [skip?: true]
                ] [
                    form value
                ]
                unless skip? [
                    repend out [" " to word! key {="} value {"}]
                ]
            ]
            unless empty? attributes [
                append out join #" " form attributes
            ]
            append out #">"
        ]
        unless parse data bind rules/main-rule rules [
            return ajoin ["LEST: there was error in LEST dialect at: " mold pos]
        ]
        body: head buffer
        unless empty? includes/style [
            write %lest-temp.css to-css precssr includes/style
            Print ["CSS wrote to file %lest-temp.css"]
        ]
        either header? [
            ajoin [
                <!DOCTYPE html> newline
                <html lang="en-US"> newline
                <head> newline
                <title> page/title </title> newline
                <meta charset="utf-8"> newline
                page/meta newline
                includes/stylesheets
                includes/header
                </head> newline
                <body data-spy="scroll" data-target=".navbar">
                includes/body-start
                body
                includes/body-end
                </body>
                </html>
            ]
        ] [
            body
        ]
    ] 'buffer
]
