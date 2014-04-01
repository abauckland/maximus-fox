-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.19 - MySQL Community Server (GPL)
-- Server OS:                    Win32
-- HeidiSQL version:             7.0.0.4053
-- Date/time:                    2014-04-01 22:18:49
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET FOREIGN_KEY_CHECKS=0 */;

-- Dumping structure for table specification_prod.featurecontents
DROP TABLE IF EXISTS `featurecontents`;
CREATE TABLE IF NOT EXISTS `featurecontents` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `feature_id` char(50) DEFAULT NULL,
  `order` tinyint(4) DEFAULT NULL,
  `title` char(50) DEFAULT NULL,
  `text` text,
  `image` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- Dumping data for table specification_prod.featurecontents: ~18 rows (approximately)
DELETE FROM `featurecontents`;
/*!40000 ALTER TABLE `featurecontents` DISABLE KEYS */;
INSERT INTO `featurecontents` (`id`, `feature_id`, `order`, `title`, `text`, `image`) VALUES
	(1, '1', 1, 'Intuitive Design', NULL, 'F1-3'),
	(2, '1', 2, 'In-line Instructions', NULL, 'F6-1'),
	(3, '1', 3, 'On-line Tutorials', NULL, 'F1-1'),
	(4, '3', 1, 'Any Device', 'The Specright mobile application allows specifications to be edited from your smart phone or tablet. This makes it ideal for those post meeting changes, allowing you to update your specifications without having to wait until you get back to the office', 'F3-1'),
	(5, '3', 2, 'Any System', NULL, 'F3-2'),
	(6, '3', 3, 'Any Place', 'Whether an individual designer working at home or a member of a dispersed design team spread across the world, Specright supports agile and flexible working patterns enabling you to work when and where you want. It also allows multiple users to work on the same document at the same time.', NULL),
	(7, '4', 1, 'Tracking', NULL, 'F4-1'),
	(8, '4', 2, 'Reporting', NULL, NULL),
	(9, '4', 3, 'Custom Specifications', NULL, 'F5-1'),
	(10, '5', 1, 'User Management', NULL, 'F5-2'),
	(11, '5', 2, 'Flexible Working', NULL, NULL),
	(12, '5', 3, 'Specification Templates', NULL, 'F6-1'),
	(13, '6', 1, 'In-line Clause Guidance', NULL, 'F6-2'),
	(14, '6', 2, 'Specright Guides', NULL, 'FG-2'),
	(15, NULL, 3, 'Specification Guides', NULL, 'FG-1'),
	(16, NULL, 1, 'Subscribe', NULL, 'FG-2'),
	(17, NULL, 2, NULL, NULL, NULL),
	(18, NULL, 3, NULL, NULL, NULL);
/*!40000 ALTER TABLE `featurecontents` ENABLE KEYS */;


-- Dumping structure for table specification_prod.features
DROP TABLE IF EXISTS `features`;
CREATE TABLE IF NOT EXISTS `features` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `title` char(50) DEFAULT NULL,
  `text` char(250) DEFAULT NULL,
  `feature_show_img` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- Dumping data for table specification_prod.features: ~9 rows (approximately)
DELETE FROM `features`;
/*!40000 ALTER TABLE `features` DISABLE KEYS */;
INSERT INTO `features` (`id`, `title`, `text`, `feature_show_img`) VALUES
	(1, 'Easy to Use', 'Specright\'s ease of use and affordability makes it the ideal specification writing tool for any design organisation, aiding both quality control and productivity', 'Easy to Use'),
	(2, 'Affordable', 'From sole practitioners to multi-nationals Specright provides an affordable and high value resource that facilitates agile working and improved performance.', 'Affordable'),
	(3, 'Any Where & Any Time', 'Edit specifications in the office or on the move. An internet or data connection is all that is required', 'Any Where & Any Time'),
	(4, 'Revision Tracking', 'Automated tracking and reporting of changes to specifications aiding quality control and transparency', 'Revision Tracking'),
	(5, 'Customisable', 'Customise Specright specification templates or create your own templates from scatch', 'Custom'),
	(6, 'Templates & Guidance', 'Trade section templates and guidance notes support efficient development of robust specifications.', 'Guidance'),
	(7, 'Office Specifications', 'Create and manage specifications. Share them throughout the organisation while revisions are automatically tracked and reported', 'Office Specifications'),
	(8, 'Project Specifications', 'Create a project specific account to allow full collaborative and auditable working across the whole project team', 'Project Specifications'),
	(9, 'Specification Guides', 'Specification guides are also available via free subscription to our mailing list. This provides direct access to all current specification guides together with notification of updates and the release of new guides.', 'Guides');
/*!40000 ALTER TABLE `features` ENABLE KEYS */;
/*!40014 SET FOREIGN_KEY_CHECKS=1 */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
productimports