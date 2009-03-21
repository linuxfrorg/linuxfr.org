CREATE TABLE `boards` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `user_agent` varchar(255) default NULL,
  `object_id` int(11) default NULL,
  `object_type` varchar(255) default NULL,
  `message` text,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `node_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `state` varchar(255) NOT NULL default 'published',
  `title` varchar(255) default NULL,
  `body` text,
  `score` int(11) default '0',
  `materialized_path` varchar(1022) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `diaries` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'published',
  `title` varchar(255) default NULL,
  `body` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `forums` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'active',
  `title` varchar(255) default NULL,
  `position` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `links` (
  `id` int(11) NOT NULL auto_increment,
  `news_id` int(11) default NULL,
  `title` varchar(255) default NULL,
  `url` varchar(255) default NULL,
  `lang` varchar(255) default NULL,
  `nb_clicks` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `news` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'draft',
  `title` varchar(255) default NULL,
  `body` text,
  `second_part` text,
  `section_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `nodes` (
  `id` int(11) NOT NULL auto_increment,
  `content_id` int(11) default NULL,
  `content_type` varchar(255) default NULL,
  `score` int(11) default '0',
  `user_id` int(11) default NULL,
  `public` tinyint(1) default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

CREATE TABLE `poll_answers` (
  `id` int(11) NOT NULL auto_increment,
  `poll_id` int(11) default NULL,
  `answer` varchar(255) default NULL,
  `votes` int(11) NOT NULL default '0',
  `position` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

CREATE TABLE `poll_ips` (
  `id` int(11) NOT NULL auto_increment,
  `ip` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_poll_ips_on_ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `polls` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'draft',
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'published',
  `title` varchar(255) default NULL,
  `body` text,
  `forum_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `relevances` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `comment_id` int(11) default NULL,
  `vote` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sections` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'published',
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `slugs` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `sluggable_id` int(11) default NULL,
  `sequence` int(11) NOT NULL default '1',
  `sluggable_type` varchar(40) default NULL,
  `scope` varchar(40) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_slugs_on_name_and_sluggable_type_and_scope_and_sequence` (`name`,`sluggable_type`,`scope`,`sequence`),
  KEY `index_slugs_on_sluggable_id` (`sluggable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `tag_id` int(11) default NULL,
  `node_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `taggings_count` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `trackers` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'open',
  `title` varchar(255) default NULL,
  `body` text,
  `category_id` int(11) default NULL,
  `assigned_to_user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(40) NOT NULL,
  `email` varchar(100) NOT NULL,
  `name` varchar(100) default NULL,
  `homesite` varchar(255) default NULL,
  `jabber_id` varchar(255) default NULL,
  `role` varchar(255) NOT NULL default 'moule',
  `state` varchar(255) NOT NULL default 'passive',
  `salt` varchar(40) default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `crypted_password` varchar(40) default NULL,
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `votes` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `node_id` int(11) default NULL,
  `vote` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `wiki_pages` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) NOT NULL default 'public',
  `title` varchar(255) default NULL,
  `body` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090105233501');

INSERT INTO schema_migrations (version) VALUES ('20090105234709');

INSERT INTO schema_migrations (version) VALUES ('20090106000348');

INSERT INTO schema_migrations (version) VALUES ('20090108232844');

INSERT INTO schema_migrations (version) VALUES ('20090108235238');

INSERT INTO schema_migrations (version) VALUES ('20090110185148');

INSERT INTO schema_migrations (version) VALUES ('20090113223625');

INSERT INTO schema_migrations (version) VALUES ('20090119235401');

INSERT INTO schema_migrations (version) VALUES ('20090120005239');

INSERT INTO schema_migrations (version) VALUES ('20090130001540');

INSERT INTO schema_migrations (version) VALUES ('20090205000452');

INSERT INTO schema_migrations (version) VALUES ('20090209225424');

INSERT INTO schema_migrations (version) VALUES ('20090209232103');

INSERT INTO schema_migrations (version) VALUES ('20090216004002');

INSERT INTO schema_migrations (version) VALUES ('20090222161451');

INSERT INTO schema_migrations (version) VALUES ('20090224230430');

INSERT INTO schema_migrations (version) VALUES ('20090301003322');

INSERT INTO schema_migrations (version) VALUES ('20090301003336');

INSERT INTO schema_migrations (version) VALUES ('20090308230814');

INSERT INTO schema_migrations (version) VALUES ('20090308232205');

INSERT INTO schema_migrations (version) VALUES ('20090310234743');