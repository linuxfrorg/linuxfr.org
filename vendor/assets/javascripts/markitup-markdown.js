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
        { name: 'Titre de niveau 1', placeHolder: 'Votre titre', className: 'h1', closeWith: function(m) { return miu.markdownTitle(m, '='); } },
        { name: 'Titre de niveau 2', placeHolder: 'Votre titre', className: 'h2', closeWith: function(m) { return miu.markdownTitle(m, '-'); } },
        { name: 'Titre de niveau 3', openWith: '### ', placeHolder: 'Votre titre', className: 'h3' },
        { name: 'Titre de niveau 4', openWith: '#### ', placeHolder: 'Votre titre', className: 'h4' },
        { separator: '---------------' },
        { name: 'Gras', openWith: '**', closeWith: '**', className: 'bold' },
        { name: 'Italique', openWith: '_', closeWith: '_', className: 'italic' },
        { name: 'Barré', openWith: '~~', closeWith: '~~', className: 'stroke' },
        { name: 'Terminal', openWith: '`', closeWith: '`', className: 'teletype' },
        { separator: '---------------' },
        { name: 'Liste à points', openWith: '- ', className: 'list-bullet'},
        { name: 'Liste ordonnée', className: 'list-numeric', openWith: function(m) { return m.line + '. '; } },
        { separator: '---------------' },
        { name: 'Image externe', openWith: '![', closeWith: ']([![Adresse:!:https://]!])', placeHolder: "Titre de l’image", className: 'image' },
        { name: 'Lien', openWith: '[', closeWith: ']([![Adresse:!:https://]!])', placeHolder: 'Texte du lien', className: 'link' },
        { separator: '---------------' },
        { name: 'Citations', openWith: '> ', className: 'quotes' },
        { name: 'Bloc de code', className: 'code', replaceWith: function(m) { return m.selection.replace(/^/mg, "    "); } }
    ]
};
