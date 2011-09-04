// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------

// mIu nameSpace to avoid conflict.
var miu = {
    markdownTitle: function(markItUp, c) {
        var heading = '\n',
            n = $.trim(markItUp.selection||markItUp.placeHolder).length,
            i;
        for(i = 0; i < n; i++) {
            heading += c;
        }
        return heading;
    }
};

window.markItUpSettings = {
    previewParserPath:    '',
    onTab: { keepDefault: true },
    onShiftEnter: { keepDefault: false, openWith: '\n\n' },
    markupSet: [
        { name: 'First Level Heading', key: '1', placeHolder: 'Votre titre', className: 'h1', closeWith: function(m) { return miu.markdownTitle(m, '='); } },
        { name: 'Second Level Heading', key: '2', placeHolder: 'Votre titre', className: 'h2', closeWith: function(m) { return miu.markdownTitle(m, '-'); } },
        { name: 'Heading 3', key: '3', openWith: '### ', placeHolder: 'Votre titre', className: 'h3' },
        { name: 'Heading 4', key: '4', openWith: '#### ', placeHolder: 'Votre titre', className: 'h4' },
        { separator: '---------------' },
        { name: 'Bold', key: 'B', openWith: '**', closeWith: '**', className: 'bold' },
        { name: 'Italic', key: 'I', openWith: '_', closeWith: '_', className: 'italic' },
        { separator: '---------------' },
        { name: 'Bulleted List', openWith: '- ', className: 'list-bullet'},
        { name: 'Numeric List', className: 'list-numeric', openWith: function(m) { return m.line + '. '; } },
        { separator: '---------------' },
        { name: 'Picture', key: 'P', openWith: '![', closeWith: ']([![Url:!:http://]!])', placeHolder: "Titre de l'image", className: 'image' },
        { name: 'Link', key: 'L', openWith: '[', closeWith: ']([![Url:!:http://]!])', placeHolder: 'Texte du lien', className: 'link' },
        { separator: '---------------' },
        { name: 'Quotes', openWith: '> ', className: 'quotes' },
        { name: 'Code Block', className: 'code', replaceWith: function(m) { return m.selection.replace(/^/mg, "    "); } }
    ]
};
