// ----------------------------------------------------------------------------
// markItUp!
// ----------------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// ----------------------------------------------------------------------------
markItUpSettings = {
    nameSpace:          "wiki",
    onShiftEnter:       {keepDefault: false, replaceWith: '\n\n'},
    markupSet:  [
        {name:'Heading 1', key:'1', openWith:'= ', closeWith:' =', placeHolder:'Votre titre', className:'h1'},
        {name:'Heading 2', key:'2', openWith:'== ', closeWith:' ==', placeHolder:'Votre titre', className:'h2'},
        {name:'Heading 3', key:'3', openWith:'=== ', closeWith:' ===', placeHolder:'Votre titre', className:'h3'},
        {name:'Heading 4', key:'4', openWith:'==== ', closeWith:' ====', placeHolder:'Votre titre', className:'h4'},
        {separator:'---------------' },
        {name:'Bold', key:'B', openWith:"'''", closeWith:"'''", className:'bold'},
        {name:'Italic', key:'I', openWith:"''", closeWith:"''", className:'italic'},
        {name:'Stroke through', key:'S', openWith:'<s>', closeWith:'</s>', className:'stroke'},
        {separator:'---------------' },
        {name:'Bulleted list', openWith:'(!(* |!|*)!)', className:'list-bullet'},
        {name:'Numeric list', openWith:'(!(# |!|#)!)', className:'list-numeric'},
        {separator:'---------------' },
        {name:'Picture', key:'P', replaceWith:'[[Image:[![Url:!:http://]!]|[![name]!]]]', className:'image'},
        {name:'Link', key:'L', openWith:'[[![Link]!] ', closeWith:']', placeHolder:'Votre texte...', className:'link'},
        {separator:'---------------' },
        {name:'Quotes', openWith:'(!(> |!|>)!)', className:'quotes'},
        {name:'Code', openWith:'<pre>)', closeWith:'</pre>', className:'code'}
    ]
}
