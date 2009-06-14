# Dictionary
Dictionary['logo'] = 'linuxfr2_gnu.png'

# Responses
Response.create(:title => "Copie de dépêche externe",    :content => "La dépêche que vous avez proposée n'est qu'une copie d'un article\nprovenant d'un autre site (en partie ou en entier).\nNous refusons ce genre d'article, même si la source est citée.")
Response.create(:title => "Dépêche trop courte",         :content => "La dépêche que vous avez proposée a été considérée trop courte pour être\nvalidée sur LinuxFr.org. En effet, nous n'acceptons que des dépêches de\nplusieurs lignes, comme celles qui passent sur le site habituellement.")
Response.create(:title => "Dépêche déjà publiée",        :content => "Le sujet de la dépêche que vous avez proposée a déjà fait l'objet d'une\ndépêche publiée sur LinuxFr.org. Pour cette raison, votre dépêche a été\nrefusée.")
Response.create(:title => "Dépêche déjà proposée",       :content => "Une ou plusieurs autres dépêches sur le même sujet a (ont) déjà été\nproposée(s) par un (ou plusieurs) autre(s) internaute(s). Dès qu'un\nmodérateur pourra s'en occuper, il utilisera celle qui lui semble la\nmieux rédigée.")
Response.create(:title => "Dépêche hors sujet",          :content => "La dépêche que vous avez envoyée est hors-sujet par rapport au site. Si\nLinuxFr.org valide parfois les dépêches hors-sujet, celle-ci n'a pas\nretenu l'attention des modérateurs.")
Response.create(:title => "Redirection forum",           :content => "Une entrée dans un forum serait plus adaptée pour poser cette question.\nNous tenons à vous remercier de l'avoir proposée, et nous\nvous encourageons à la poser dans un des forums du site.\n\nhttp://linuxfr.org/posts/nouveau")
Response.create(:title => "Redirection journal",         :content => "Votre journal est peut-être plus adapté pour passer cette information.\n\nhttp://linuxfr.org//journaux/nouveau")
Response.create(:title => "Problèmes de rédaction",      :content => "Cette dépêche pose des problèmes de rédaction, et il nous est difficile\nde la valider telle quelle. Pourriez-vous re-rédiger cette dépêche s'il\nvous plaît ?")
Response.create(:title => "Site (presque) vide",         :content => "LinuxFr.org préfère valider des dépêches de ce type quand le site est\ndéjà bien avancé. Si d'ici quelques temps, c'est le cas, n'hésitez pas\nà re-proposer une dépêche.")
Response.create(:title => "Version mineure du logiciel", :content => "Votre dépêche traite d'une version mineure d'un logiciel, et n'apporte\nrien de fort d'un point de vue information. Pour cette raison elle a été\nrefusée.")

