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
%w(Autres Administration\ site Commentaires Feuilles\ de\ style\ (CSS) Dépêches Forums Journaux Modération Proposition Recherche Sondages Suivi Barre\ d’outils Tribune Wiki Avatars Étiquettes Vieux\ navigateurs Comptes\ utilisateurs Statistiques Rédaction Administration\ système À\ ranger\ quelque\ part Aide\ et\ documentation Notifications Syntaxe\ markdown API\ OAuth Images Flux\ Atom Epub Liens).each do |cat|
  Category.create!(title: cat)
end

# Responses
Response.create!(title: "Copie de dépêche externe",    content: "La dépêche que vous avez proposée n’est qu’une copie d’un article\nprovenant d’un autre site (en partie ou en entier).\nNous refusons ce genre d’article, même si la source est citée.")
Response.create!(title: "Dépêche trop courte",         content: "La dépêche que vous avez proposée a été considérée trop courte pour être\nvalidée sur LinuxFr.org. En effet, nous n’acceptons que des dépêches de\nplusieurs lignes, comme celles qui passent sur le site habituellement.")
Response.create!(title: "Dépêche déjà publiée",        content: "Le sujet de la dépêche que vous avez proposée a déjà fait l’objet d’une\ndépêche publiée sur LinuxFr.org. Pour cette raison, votre dépêche a été\nrefusée.")
Response.create!(title: "Dépêche déjà proposée",       content: "Une ou plusieurs autres dépêches sur le même sujet a (ont) déjà été\nproposée(s) par un (ou plusieurs) autre(s) internaute(s). Dès que\nl’équipe de modération pourra s’en occuper, elle utilisera celle qui\nlui semble la mieux rédigée.")
Response.create!(title: "Dépêche hors sujet",          content: "La dépêche que vous avez envoyée est hors sujet par rapport au site. Si\nLinuxFr.org valide parfois les dépêches hors sujet, celle‑ci n’a pas\nretenu l’attention de l’équipe de modération.")
Response.create!(title: "Problèmes de rédaction",      content: "Nous vous remercions de nous avoir soumis cette dépêche. Mais, en\nl’état, elle pose des problèmes de rédaction, et il nous est\ndifficile de la valider. Pourriez-vous la re-rédiger s’il vous\nplaît ? Vous trouverez l’ensemble des remarques qui ont été émises\npour vous aider à l’améliorer dans la discussion de la dépêche :\ncolonne à droite si vous passez par un ordinateur, ou appui sur\nl’icône en bas à droite pour la faire apparaître si vous utilisez\nun terminal mobile.")
Response.create!(title: "Redirection forum",           content: "Une entrée dans un forum serait plus adaptée pour poser cette question.\nNous tenons à vous remercier de l’avoir proposée, et nous\nvous encourageons à la poser dans un des forums du site.\n\nhttps://linuxfr.org/posts/nouveau")
Response.create!(title: "Redirection journal",         content: "Votre journal est peut‑être plus adapté pour passer cette information.\n\nhttps://linuxfr.org/journaux/nouveau")
Response.create!(title: "Site (presque) vide",         content: "LinuxFr.org préfère valider des dépêches de ce type quand le site est\ndéjà bien avancé. Si tel est le cas dans quelque temps, n’hésitez pas\nà proposer une nouvelle dépêche.")
Response.create!(title: "Version mineure du logiciel", content: "Votre dépêche traite d’une version mineure d’un logiciel, et n’apporte\nrien de fort d’un point de vue information. Pour cette raison, elle a été\nrefusée.")
Response.create!(title: "Redirection Agenda du libre", content: "LinuxFr.org publie chaque week-end les événements de la semaine à venir\nqui ont été soumis sur le site de l’Agenda du Libre https://agendadulibre.org .\n\nNous vous invitons donc à soumettre votre événement sur le site de l’Agenda\ndu Libre si vous ne l’avez pas déjà fait. Nous republierons cet événement\nautomatiquement ensuite sur LinuxFr.org.")
Response.create!(title: "Dépêche à l’abandon", content: "La dépêche que vous avez proposée est restée très longtemps dans\nl’espace de rédaction collaboratif sans aucune modification alors qu’elle\nn’est pas terminée.\n\nConsidérant ce contenu abandonné, et pour conserver un certain\ndynamisme dans l’espace de rédaction collaboratif, nous préférons le\nrefuser.\n\nRien ne vous empêche de le proposer à nouveau si besoin.")

# Friend sites
FriendSite.create!(title: "Agenda du Libre", url: "https://www.agendadulibre.org/")
FriendSite.create!(title: "April", url: "https://www.april.org/")
FriendSite.create!(title: "Éditions Diamond", url: "https://boutique.ed-diamond.com/")
FriendSite.create!(title: "Éditions ENI", url: "https://www.editions-eni.fr/livres/open-source/.12659ab71294b44082200c97a40710bc.html")
FriendSite.create!(title: "Éditions Eyrolles", url: "https://www.editions-eyrolles.com/Recherche/?q=linux")
FriendSite.create!(title: "Framasoft", url: "https://www.framasoft.net/")
FriendSite.create!(title: "Grafik Plus", url: "https://grafik.plus/")
FriendSite.create!(title: "La Quadrature du Net", url: "https://www.laquadrature.net/")
FriendSite.create!(title: "Léa-Linux", url: "https://lea-linux.org/")
FriendSite.create!(title: "LinuxGraphic", url: "https://www.linuxgraphic.org/")
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

# Admin account
admin = Account.new
admin.login = "admin"
admin.role = "admin"
admin.email = "admin@dlfp.lo"
admin.skip_confirmation!
admin.save!

# Reset automatically generated password
admin.password = "admin"
admin.password_confirmation = "admin"
admin.save!

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

### Les sections du site
- [Aide sur les différentes sections du site et la page d’accueil](https://linuxfr.org/aide#aide-sections)
- [Rédaction](/wiki/redaction "Lien du wiki interne LinuxFr.org") : espace de contribution.
- [Plan](https://linuxfr.org/plan) : plan du site
- [Tags](/wiki/tags "Lien du wiki interne LinuxFr.org") : étiquettes permettant la classification de l’information
- [CSS](/wiki/css "Lien du wiki interne LinuxFr.org") : le code de vos CSS, ou vos modifications des CSS existantes
- [Changelog](https://linuxfr.org/changelog) : pour visualiser, sans le détail, l’historique des changements apportés au site
- [Tribune](/wiki/tribune "Lien du wiki interne LinuxFr.org") : chat ou salon de discussion.
- [Statistiques](https://linuxfr.org/statistiques) : des informations statistiques sur le site LinuxFr.org, en termes de fréquentation, des contenus ou commentaires publiés, etc.

### Aide
- [FAQ](https://linuxfr.org/aide) : une foire aux questions pour aider les débutants (et les utilisateurs plus réguliers) à mieux connaître le site.
- [Aide à l’édition](/wiki/aide-edition "Lien du wiki interne LinuxFr.org") : page d’aide sur la syntaxe Markdown.
- [Bac à sable](/wiki/Bac-A-Sable "Lien du wiki interne LinuxFr.org") : faites-vous plaisir et expérimentez, cette page est là pour ça.
- [Rédaction](/wiki/redaction "Lien du wiki interne LinuxFr.org") : pour rédiger des dépêches de manière collaborative entre utilisateurs de LinuxFr.org.
  - ne serait‐ce que pour traduction classique pour lesquelles nous avons des [[[traductions classiques]]] qui ne demandent qu’à être complétées !
- [Participer à LinuxFr.org](/wiki/participer-a-linuxfr "Lien du wiki interne LinuxFr.org") que ce soit pour une [CSS](/wiki/css "Lien du wiki interne LinuxFr.org") ou pour proposer une dépêche dans l’espace de rédaction
- [Découvrir LinuxFr.org](/wiki/decouvrir-linuxfr "Lien du wiki interne LinuxFr.org") pour une synthèse des liens pour un nouvel inscrit
- [Rédiger une offre d’emploi](https://linuxfr.org/forums/general-petites-annonces/posts/emploi-embauche-developpeurs-linux-kernel-pourvu#comment-1622396) indique les critères pour qu’une offre d’emploi soit bien accueillie sur [[[LinuxFr.org]]].
- [Poser une question](/wiki/poser-une-question-oui-mais-quoi-comment) permet de vous guider lorsque vous avez une question à poser [[[LinuxFr.org]]].

# Développement du site
- [LinuxFr.org et IPv6](/wiki/ipv6 "Lien du wiki interne LinuxFr.org")
- [Coordination des tests](/wiki/Coordination-des-tests "Lien du wiki interne LinuxFr.org")
- [CSS-LinuxFr.org](/wiki/CSS-LinuxFR "Lien du wiki interne LinuxFr.org")
- [Modération](/wiki/Modération "Lien du wiki interne LinuxFr.org") : fonctionnalité de LinuxFr.org pour la modération
- [fonctionnalité Agenda du Libre](/wiki/fonctionnalite-agenda-du-libre "Lien du wiki interne LinuxFr.org") pour faire bénéficier les lecteurs de LinuxFr.org de <https://agendadulibre.org>  ou <https://www.agendadulibre.qc.ca>.

# Promotion du site
Le site _LinuxFr.org_ vit grâce aux contributions de ses visiteurs et lecteurs qui sont invités à proposer du contenu. Pour se faire connaître, plusieurs actions sont possibles dont :

- la participation à des salons ou événements, tels Solutions Linux, JM2L, RMLL, etc. Cela peut passer par :
  - la [tenue d’un stand LinuxFr.org](/wiki/tenue-d-un-stand-linuxfr "Lien du wiki interne LinuxFr.org"),
  - une conférence ;
- des entretiens à des magazines ;
- l’accueil des nouveaux :
  - ils peuvent se faire remarquer par leurs journaux,
  - la participation en rédaction est un autre moyen,
  - généralement, ni le wiki, ni la FAQ ne permettent de motiver ni d’inciter à participer, cela permet uniquement d’indiquer les pratiques appliquées (pas forcément les plus efficaces et pouvant être discutées, c’est l’objet d’une ML et d’un wiki : approfondir, via la discussion).
- etc.
EOS
wp.save!
wp.reload
wp.node.update_column(:user_id, 1)
