# encoding: UTF-8

# The logo
Logo.image = '/images/logos/linuxfr2_classic.png'

# Langs
Lang['fr'] = 'Français'
Lang['de'] = 'Allemand'
Lang['en'] = 'Anglais'
Lang['eu'] = 'Basque'
Lang['ct'] = 'Catalan'
Lang['cn'] = 'Chinois'
Lang['ko'] = 'Coréen'
Lang['da'] = 'Danois'
Lang['es'] = 'Espagnol'
Lang['ee'] = 'Estonien'
Lang['fi'] = 'Finnois'
Lang['el'] = 'Grec'
Lang['it'] = 'Italien'
Lang['ja'] = 'Japonais'
Lang['nl'] = 'Néerlandais'
Lang['no'] = 'Norvégien'
Lang['pl'] = 'Polonais'
Lang['pt'] = 'Portugais'
Lang['ru'] = 'Russe'
Lang['sv'] = 'Suédois'
Lang['xx'] = '!? hmmm ?!'
Lang['wq'] = 'Code/binaire'

# Category
%w(Autres Administration\ site Commentaires Feuilles\ de\ style\ (CSS) Dépêches Forums Journaux Modération Proposition Recherche Sondages Suivi Barre\ d’outil Tribune Wiki Avatars Étiquettes Vieux\ navigateurs Comptes\ utilisateurs Statistiques Rédaction Administration\ système À\ ranger\ quelque\ part Aide\ et\ documentation Notifications Syntaxe\ markdown API\ OAuth Images Flux\ Atom Epub Liens).each do |cat|
  Category.create!(title: cat)
end

# Responses
Response.create!(title: "Copie de dépêche externe",    content: "La dépêche que vous avez proposée n’est qu’une copie d’un article\nprovenant d’un autre site (en partie ou en entier).\nNous refusons ce genre d’article, même si la source est citée.")
Response.create!(title: "Dépêche trop courte",         content: "La dépêche que vous avez proposée a été considérée trop courte pour être\nvalidée sur LinuxFr.org. En effet, nous n’acceptons que des dépêches de\nplusieurs lignes, comme celles qui passent sur le site habituellement.")
Response.create!(title: "Dépêche déjà publiée",        content: "Le sujet de la dépêche que vous avez proposée a déjà fait l’objet d’une\ndépêche publiée sur LinuxFr.org. Pour cette raison, votre dépêche a été\nrefusée.")
Response.create!(title: "Dépêche déjà proposée",       content: "Une ou plusieurs autres dépêches sur le même sujet a (ont) déjà été\nproposée(s) par un (ou plusieurs) autre(s) internaute(s). Dès qu’un\nmodérateur pourra s’en occuper, il utilisera celle qui lui semble la\nmieux rédigée.")
Response.create!(title: "Dépêche hors sujet",          content: "La dépêche que vous avez envoyée est hors sujet par rapport au site. Si\nLinuxFr.org valide parfois les dépêches hors sujet, celle‑ci n’a pas\nretenu l’attention des modérateurs.")
Response.create!(title: "Problèmes de rédaction",      content: "Cette dépêche pose des problèmes de rédaction, et il nous est difficile\nde la valider telle quelle. Pourriez‑vous re‑rédiger cette dépêche s’il\nvous plaît ?")
Response.create!(title: "Redirection forum",           content: "Une entrée dans un forum serait plus adaptée pour poser cette question.\nNous tenons à vous remercier de l’avoir proposée, et nous\nvous encourageons à la poser dans un des forums du site.\n\nhttps://linuxfr.org/posts/nouveau")
Response.create!(title: "Redirection journal",         content: "Votre journal est peut‑être plus adapté pour passer cette information.\n\nhttps://linuxfr.org//journaux/nouveau")
Response.create!(title: "Site (presque) vide",         content: "LinuxFr.org préfère valider des dépêches de ce type quand le site est\ndéjà bien avancé. Si tel est le cas dans quelque temps, n’hésitez pas\nà proposer une nouvelle dépêche.")
Response.create!(title: "Version mineure du logiciel", content: "Votre dépêche traite d’une version mineure d’un logiciel, et n’apporte\nrien de fort d’un point de vue information. Pour cette raison, elle a été\nrefusée.")
Response.create!(title: "Redirection Agenda du libre", content: "LinuxFr.org publie chaque week-end les événements de la semaine à venir qui ont été soumis sur le site de l’Agenda du Libre https://agendadulibre.org .\n\nNous vous invitons donc à soumettre votre événement sur le site de l’Agenda du Libre si vous ne l’avez pas déjà fait. Nous republierons cet événement automatiquement ensuite sur LinuxFr.org.")
Response.create!(title: "Dépêche à l’abandon", content: "La dépêche que vous avez proposée est restée très longtemps dans l’espace de rédaction collaboratif sans aucune modification alors qu’elle n’est pas terminée.\n\nConsidérant ce contenu abandonné, et pour conserver un certain dynamisme dans l’espace de rédaction collaboratif, nous préférons le refuser.\n\nRien ne vous empêche de le proposer à nouveau si besoin.")

# Friend sites
FriendSite.create!(title: "Agenda du Libre", url: "https://www.agendadulibre.org/")
FriendSite.create!(title: "April", url: "https://www.april.org/")
FriendSite.create!(title: "Éditions Diamond", url: "https://boutique.ed-diamond.com/")
FriendSite.create!(title: "Éditions ENI", url: "https://www.editions-eni.fr/livres/open-source/.12659ab71294b44082200c97a40710bc.html")
FriendSite.create!(title: "Éditions Eyrolles", url: "https://www.editions-eyrolles.com/Recherche/?q=linux")
FriendSite.create!(title: "Framasoft", url: "https://www.framasoft.net/")
FriendSite.create!(title: "Grafik Plus", url: "https://www.gp3.fr/")
FriendSite.create!(title: "JeSuisLibre", url: "http://www.jesuislibre.org/")
FriendSite.create!(title: "La Quadrature du Net", url: "https://www.laquadrature.net/")
FriendSite.create!(title: "Léa-Linux", url: "https://lea-linux.org/")
FriendSite.create!(title: "LinuxGraphic", url: "https://www.linuxgraphic.org/")
FriendSite.create!(title: "Lolix", url: "http://fr.lolix.org/")
FriendSite.create!(title: "Veni, Vedi, Libri", url: "https://vvlibri.org/")
FriendSite.create!(title: "TuxFamily", url: "https://tuxfamily.org")
FriendSite.create!(title: "En Vente Libre", url: "https://enventelibre.org")

# Pages
dir = File.join(File.dirname(__FILE__), 'pages')
Dir.chdir(dir) do
  Dir["*.html"].each do |file|
    slug  = File.basename(file, '.html')
    body  = File.read(file)
    title = slug.capitalize.tr('_', ' ')
    Page.create!(slug: slug, title: title, body: body)
  end
end

# Anonymous account
Account.reset_column_information
anon = Account.new
anon.login = "Anonyme"
anon.role  = "inactive"
anon.email = "anonyme@linuxfr.org"
anon.encrypted_password = "XXX"
anon.skip_confirmation!
anon.save!

# Collective user
User.create! name: "Collectif"

# Default section is defined by it's title (required to be able to create news)
Section.create! title: "LinuxFr.org"

# Wiki
wp = WikiPage.new
wp.title = WikiPage::HomePage
wp.wiki_body = <<EOS
Le wiki de LinuxFr.org
======================

Fonctionnement
--------------
Cet espace est un [wiki](https://fr.wikipedia.org/wiki/Wiki), c’est‑à‑dire un endroit où tous les utilisateurs (du moins, ceux qui sont authentifiés) peuvent écrire.
Pour créer une page, le plus simple est de faire un lien vers cette dernière en utilisant la syntaxe `[[[`MaPage`]]]`, puis de cliquer sur ce lien.
Si la page n’existe pas encore, un formulaire vous sera proposé pour la créer.

Les pages principales
---------------------
C’est à **vous** de jouer et de créer ces pages. ;-)
Voici quelques pages qu’il serait intéressant d’avoir :

- [[[FAQ]]] : une foire aux questions pour aider les débutants (et les utilisateurs plus réguliers) à mieux connaître le site ;
- [[[PierreTramo]]], [[[42]]], [[[Templeet]]] : le bestiaire de _LinuxFr.org_ ;
- [[[Astuces]]] : des astuces sur GNU/Linux et les logiciels libres.
EOS
wp.save!
wp.reload
wp.node.update_column(:user_id, 1)
