// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------
// MarkDown tags example
// http://en.wikipedia.org/wiki/Markdown
// http://daringfireball.net/projects/markdown/
// -------------------------------------------------------------------
// Feel free to add more tags
// -------------------------------------------------------------------
var markItUpSettings = {
	previewParserPath:	'',
	onShiftEnter:		{keepDefault:false, openWith:'\n\n'},
	markupSet: [
		{name:'First Level Heading', key:'1', placeHolder:'Votre titre', className:'h1', closeWith:function(markItUp) { return miu.markdownTitle(markItUp, '=') } },
		{name:'Second Level Heading', key:'2', placeHolder:'Votre titre', className:'h2', closeWith:function(markItUp) { return miu.markdownTitle(markItUp, '-') } },
		{name:'Heading 3', key:'3', openWith:'### ', placeHolder:'Votre titre', className:'h3' },
		{name:'Heading 4', key:'4', openWith:'#### ', placeHolder:'Votre titre', className:'h4' },
		{separator:'---------------' },		
		{name:'Bold', key:'B', openWith:'**', closeWith:'**', className:'bold'},
		{name:'Italic', key:'I', openWith:'_', closeWith:'_', className:'italic'},
		{separator:'---------------' },
		{name:'Bulleted List', openWith:'- ', className:'list-bullet'},
		{name:'Numeric List', openWith:function(markItUp) {
			return markItUp.line+'. ';
		}, className:'list-numeric'},
		{separator:'---------------' },
		{name:'Picture', key:'P', replaceWith:'![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")', className:'image'},
		{name:'Link', key:'L', openWith:'[', closeWith:']([![Url:!:http://]!] "[![Title]!]")', placeHolder:'Votre texte...', className:'link'},
		{separator:'---------------'},	
		{name:'Quotes', openWith:'> ', className:'quotes'},
		{name:'Code Block / Code', openWith:'(!(\t|!|`)!)', closeWith:'(!(`)!)', className:'code'},
	]
}

// mIu nameSpace to avoid conflict.
var miu = {
	markdownTitle: function(markItUp, char) {
		heading = '';
		n = $.trim(markItUp.selection||markItUp.placeHolder).length;
		for(i = 0; i < n; i++) {
			heading += char;
		}
		return '\n'+heading;
	}
}
