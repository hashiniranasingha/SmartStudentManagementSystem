-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 15, 2026 at 11:29 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sms1`
--

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `att_id` int(11) NOT NULL,
  `student_id` int(11) DEFAULT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `att_date` date NOT NULL,
  `att_time` time NOT NULL,
  `status` enum('Present','Absent','Late') DEFAULT 'Present',
  `att_month` int(11) GENERATED ALWAYS AS (month(`att_date`)) STORED,
  `att_year` int(11) GENERATED ALWAYS AS (year(`att_date`)) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`att_id`, `student_id`, `dept_id`, `att_date`, `att_time`, `status`) VALUES
(1, 9, 5, '2026-07-03', '23:00:00', 'Present'),
(2, 47, 4, '2026-07-09', '19:57:26', 'Late'),
(3, 11, 5, '2026-07-09', '19:58:36', 'Late'),
(4, 50, 4, '2026-07-09', '20:01:16', 'Late'),
(5, 50, 4, '2026-07-10', '20:56:35', 'Late'),
(6, 12, 5, '2026-07-10', '21:07:09', 'Late'),
(7, 26, 2, '2026-07-11', '08:39:57', 'Present'),
(8, 61, 1, '2026-07-11', '08:40:08', 'Present'),
(9, 60, 1, '2026-07-11', '08:40:17', 'Present'),
(10, 57, 1, '2026-07-11', '08:40:27', 'Present'),
(11, 5, 5, '2026-07-11', '08:41:03', 'Present'),
(12, 15, 5, '2026-07-11', '08:41:29', 'Present'),
(13, 18, 5, '2026-07-11', '08:41:38', 'Present'),
(14, 49, 4, '2026-07-11', '08:41:46', 'Present'),
(15, 64, 1, '2026-07-11', '08:41:55', 'Present'),
(16, 9, 5, '2026-07-11', '08:42:07', 'Present'),
(17, 63, 1, '2026-07-11', '08:42:14', 'Present'),
(18, 62, 1, '2026-07-11', '08:42:28', 'Present'),
(19, 20, 2, '2026-07-11', '08:42:46', 'Present'),
(20, 14, 5, '2026-07-11', '08:42:54', 'Present'),
(21, 17, 5, '2026-07-11', '08:43:06', 'Present'),
(22, 16, 5, '2026-07-11', '08:43:19', 'Present'),
(23, 13, 5, '2026-07-11', '08:43:29', 'Present'),
(24, 6, 4, '2026-07-11', '08:43:36', 'Present'),
(25, 47, 4, '2026-07-11', '08:43:48', 'Present'),
(26, 30, 3, '2026-07-11', '08:45:33', 'Present'),
(27, 28, 2, '2026-07-11', '08:45:42', 'Present'),
(28, 48, 4, '2026-07-11', '08:45:51', 'Present'),
(29, 25, 2, '2026-07-11', '08:45:59', 'Present'),
(30, 27, 2, '2026-07-11', '08:46:10', 'Present'),
(31, 3, 2, '2026-07-11', '08:46:17', 'Present'),
(32, 33, 3, '2026-07-11', '08:46:30', 'Present'),
(33, 52, 4, '2026-07-11', '08:47:31', 'Present'),
(34, 11, 5, '2026-07-11', '08:47:42', 'Present'),
(35, 59, 1, '2026-07-11', '08:48:24', 'Present'),
(36, 24, 2, '2026-07-11', '08:48:30', 'Present'),
(37, 53, 4, '2026-07-11', '08:48:57', 'Present'),
(38, 32, 3, '2026-07-11', '08:49:15', 'Present'),
(39, 36, 3, '2026-07-11', '08:49:34', 'Present'),
(40, 38, 3, '2026-07-11', '08:49:47', 'Present'),
(41, 10, 5, '2026-07-11', '08:49:56', 'Present'),
(42, 12, 5, '2026-07-11', '08:50:41', 'Present'),
(43, 7, 4, '2026-07-11', '08:51:09', 'Present'),
(44, 31, 3, '2026-07-11', '08:53:02', 'Present'),
(45, 37, 3, '2026-07-11', '08:53:09', 'Present'),
(46, 19, 5, '2026-07-11', '08:53:25', 'Present'),
(47, 22, 2, '2026-07-11', '08:54:05', 'Present'),
(48, 8, 5, '2026-07-11', '08:54:11', 'Present'),
(49, 21, 2, '2026-07-11', '08:55:08', 'Present'),
(50, 58, 1, '2026-07-11', '08:55:13', 'Present'),
(51, 2, 1, '2026-07-11', '08:57:06', 'Present'),
(52, 46, 1, '2026-07-11', '09:01:06', 'Present'),
(53, 51, 4, '2026-07-11', '09:04:34', 'Present'),
(54, 34, 3, '2026-07-11', '09:07:59', 'Present'),
(55, 4, 3, '2026-07-11', '09:23:19', 'Late'),
(56, 35, 3, '2026-07-11', '09:24:15', 'Late'),
(57, 54, 4, '2026-07-11', '09:25:36', 'Late'),
(58, 14, 5, '2026-07-12', '08:30:18', 'Present'),
(59, 12, 5, '2026-07-12', '08:30:38', 'Present'),
(60, 5, 5, '2026-07-12', '08:30:49', 'Present'),
(61, 26, 2, '2026-07-12', '08:31:05', 'Present'),
(62, 25, 2, '2026-07-12', '08:31:13', 'Present'),
(63, 8, 5, '2026-07-12', '08:31:25', 'Present'),
(64, 48, 4, '2026-07-12', '08:31:38', 'Present'),
(65, 47, 4, '2026-07-12', '08:31:52', 'Present'),
(66, 16, 5, '2026-07-12', '08:32:01', 'Present'),
(67, 27, 2, '2026-07-12', '08:32:06', 'Present'),
(68, 21, 2, '2026-07-12', '08:32:13', 'Present'),
(69, 13, 5, '2026-07-12', '08:32:20', 'Present'),
(70, 51, 4, '2026-07-12', '08:32:37', 'Present'),
(71, 17, 5, '2026-07-12', '08:32:49', 'Present'),
(72, 50, 4, '2026-07-12', '08:33:43', 'Present'),
(73, 7, 4, '2026-07-12', '08:34:00', 'Present'),
(74, 49, 4, '2026-07-12', '08:34:12', 'Present'),
(75, 53, 4, '2026-07-12', '08:34:17', 'Present'),
(76, 6, 4, '2026-07-12', '08:34:24', 'Present'),
(77, 10, 5, '2026-07-12', '08:34:34', 'Present'),
(78, 9, 5, '2026-07-12', '08:34:49', 'Present'),
(79, 59, 1, '2026-07-12', '08:34:57', 'Present'),
(80, 3, 2, '2026-07-12', '08:35:03', 'Present'),
(81, 64, 1, '2026-07-12', '08:35:14', 'Present'),
(82, 62, 1, '2026-07-12', '08:35:20', 'Present'),
(83, 57, 1, '2026-07-12', '08:35:25', 'Present'),
(84, 63, 1, '2026-07-12', '08:35:44', 'Present'),
(85, 2, 1, '2026-07-12', '08:35:52', 'Present'),
(86, 33, 3, '2026-07-12', '08:36:19', 'Present'),
(87, 18, 5, '2026-07-12', '08:36:29', 'Present'),
(88, 35, 3, '2026-07-12', '08:36:42', 'Present'),
(89, 15, 5, '2026-07-12', '08:36:54', 'Present'),
(90, 65, 4, '2026-07-12', '08:37:08', 'Present'),
(91, 38, 3, '2026-07-12', '08:37:16', 'Present'),
(92, 29, 2, '2026-07-12', '08:58:56', 'Present'),
(93, 58, 1, '2026-07-12', '09:00:02', 'Present'),
(94, 11, 5, '2026-07-12', '09:00:24', 'Present'),
(95, 20, 2, '2026-07-12', '09:01:15', 'Present'),
(96, 54, 4, '2026-07-12', '09:02:07', 'Present'),
(97, 46, 1, '2026-07-12', '09:03:05', 'Present'),
(98, 4, 3, '2026-07-12', '09:22:08', 'Late'),
(99, 31, 3, '2026-07-12', '09:22:26', 'Late'),
(100, 34, 3, '2026-07-12', '09:23:02', 'Late'),
(101, 52, 4, '2026-07-12', '09:24:14', 'Late'),
(102, 32, 3, '2026-07-12', '09:24:21', 'Late'),
(103, 2, 1, '2026-07-13', '08:39:35', 'Present'),
(104, 5, 5, '2026-07-13', '08:40:08', 'Present'),
(105, 60, 1, '2026-07-13', '08:40:26', 'Present'),
(106, 62, 1, '2026-07-13', '08:40:32', 'Present'),
(107, 57, 1, '2026-07-13', '08:40:38', 'Present'),
(108, 61, 1, '2026-07-13', '08:40:44', 'Present'),
(109, 17, 5, '2026-07-13', '08:40:53', 'Present'),
(110, 16, 5, '2026-07-13', '08:40:58', 'Present'),
(111, 8, 5, '2026-07-13', '08:41:05', 'Present'),
(112, 26, 2, '2026-07-13', '08:41:12', 'Present'),
(113, 25, 2, '2026-07-13', '08:41:18', 'Present'),
(114, 14, 5, '2026-07-13', '08:41:26', 'Present'),
(115, 11, 5, '2026-07-13', '08:41:32', 'Present'),
(116, 13, 5, '2026-07-13', '08:41:37', 'Present'),
(117, 21, 2, '2026-07-13', '08:41:44', 'Present'),
(118, 22, 2, '2026-07-13', '08:42:03', 'Present'),
(119, 66, 1, '2026-07-13', '08:42:18', 'Present'),
(120, 51, 4, '2026-07-13', '08:42:34', 'Present'),
(121, 27, 2, '2026-07-13', '08:42:52', 'Present'),
(122, 54, 4, '2026-07-13', '08:42:58', 'Present'),
(123, 47, 4, '2026-07-13', '08:43:15', 'Present'),
(124, 67, 2, '2026-07-13', '08:43:33', 'Present'),
(125, 9, 5, '2026-07-13', '08:43:42', 'Present'),
(126, 63, 1, '2026-07-13', '08:43:53', 'Present'),
(127, 50, 4, '2026-07-13', '08:44:00', 'Present'),
(128, 12, 5, '2026-07-13', '08:44:18', 'Present'),
(129, 19, 5, '2026-07-13', '08:44:30', 'Present'),
(130, 28, 2, '2026-07-13', '08:44:40', 'Present'),
(131, 37, 3, '2026-07-13', '08:44:48', 'Present'),
(132, 15, 5, '2026-07-13', '08:45:01', 'Present'),
(133, 18, 5, '2026-07-13', '08:45:07', 'Present'),
(134, 46, 1, '2026-07-13', '08:45:14', 'Present'),
(135, 49, 4, '2026-07-13', '08:45:22', 'Present'),
(136, 72, 1, '2026-07-13', '08:45:28', 'Present'),
(137, 3, 2, '2026-07-13', '08:45:48', 'Present'),
(138, 20, 2, '2026-07-13', '08:45:55', 'Present'),
(139, 10, 5, '2026-07-13', '08:46:09', 'Present'),
(140, 52, 4, '2026-07-13', '08:47:04', 'Present'),
(141, 53, 4, '2026-07-13', '08:47:35', 'Present'),
(142, 30, 3, '2026-07-13', '08:47:42', 'Present'),
(143, 35, 3, '2026-07-13', '08:47:50', 'Present'),
(144, 31, 3, '2026-07-13', '08:48:01', 'Present'),
(145, 58, 1, '2026-07-13', '08:48:09', 'Present'),
(146, 38, 3, '2026-07-13', '08:48:16', 'Present'),
(147, 71, 1, '2026-07-13', '08:49:23', 'Present'),
(148, 70, 1, '2026-07-13', '08:49:29', 'Present'),
(149, 69, 1, '2026-07-13', '08:49:37', 'Present'),
(150, 64, 1, '2026-07-13', '08:50:21', 'Present'),
(151, 68, 3, '2026-07-13', '08:51:08', 'Present'),
(152, 32, 3, '2026-07-13', '08:51:16', 'Present'),
(153, 34, 3, '2026-07-13', '09:10:29', 'Present'),
(154, 4, 3, '2026-07-13', '09:11:40', 'Present'),
(155, 36, 3, '2026-07-13', '09:11:56', 'Present'),
(156, 6, 4, '2026-07-13', '09:20:11', 'Late'),
(157, 65, 4, '2026-07-13', '09:20:23', 'Late'),
(158, 33, 3, '2026-07-13', '09:20:38', 'Late'),
(159, 7, 4, '2026-07-13', '09:21:26', 'Late'),
(160, 74, 1, '2026-07-13', '17:39:56', 'Late'),
(161, 4, 3, '2026-07-14', '12:25:18', 'Late'),
(162, 31, 3, '2026-07-14', '12:25:27', 'Late'),
(163, 35, 3, '2026-07-14', '12:25:35', 'Late'),
(164, 32, 3, '2026-07-14', '12:25:43', 'Late'),
(165, 33, 3, '2026-07-14', '12:25:53', 'Late'),
(166, 74, 1, '2026-07-14', '12:26:39', 'Late'),
(167, 9, 5, '2026-07-14', '12:26:58', 'Late'),
(168, 22, 2, '2026-07-14', '12:27:04', 'Late'),
(169, 8, 5, '2026-07-14', '12:27:11', 'Late'),
(170, 60, 1, '2026-07-15', '08:36:20', 'Present'),
(171, 20, 2, '2026-07-15', '08:36:37', 'Present'),
(172, 28, 2, '2026-07-15', '08:36:43', 'Present'),
(173, 61, 1, '2026-07-15', '08:36:47', 'Present'),
(174, 5, 5, '2026-07-15', '08:36:53', 'Present'),
(175, 25, 2, '2026-07-15', '08:36:59', 'Present'),
(176, 48, 4, '2026-07-15', '08:37:05', 'Present'),
(177, 51, 4, '2026-07-15', '08:37:14', 'Present'),
(178, 72, 1, '2026-07-15', '08:37:20', 'Present'),
(179, 27, 2, '2026-07-15', '08:37:25', 'Present'),
(180, 69, 1, '2026-07-15', '08:37:31', 'Present'),
(181, 70, 1, '2026-07-15', '08:37:39', 'Present'),
(182, 11, 5, '2026-07-15', '08:37:45', 'Present'),
(183, 8, 5, '2026-07-15', '08:37:50', 'Present'),
(184, 14, 5, '2026-07-15', '08:37:57', 'Present'),
(185, 3, 2, '2026-07-15', '08:38:03', 'Present'),
(186, 50, 4, '2026-07-15', '08:38:10', 'Present'),
(187, 26, 2, '2026-07-15', '08:38:16', 'Present'),
(188, 15, 5, '2026-07-15', '08:38:21', 'Present'),
(189, 18, 5, '2026-07-15', '08:38:27', 'Present'),
(190, 24, 2, '2026-07-15', '08:38:34', 'Present'),
(191, 17, 5, '2026-07-15', '08:38:40', 'Present'),
(192, 73, 1, '2026-07-15', '08:38:44', 'Present'),
(193, 66, 1, '2026-07-15', '08:38:49', 'Present'),
(194, 74, 1, '2026-07-15', '08:38:58', 'Present'),
(195, 47, 4, '2026-07-15', '08:39:05', 'Present'),
(196, 53, 4, '2026-07-15', '08:39:22', 'Present'),
(197, 49, 4, '2026-07-15', '08:39:28', 'Present'),
(198, 71, 1, '2026-07-15', '08:39:57', 'Present'),
(199, 63, 1, '2026-07-15', '08:40:02', 'Present'),
(200, 62, 1, '2026-07-15', '08:40:08', 'Present'),
(201, 64, 1, '2026-07-15', '08:40:20', 'Present'),
(202, 57, 1, '2026-07-15', '08:40:27', 'Present'),
(203, 9, 5, '2026-07-15', '08:40:37', 'Present');

-- --------------------------------------------------------

--
-- Table structure for table `attendance_sessions`
--

CREATE TABLE `attendance_sessions` (
  `session_id` int(11) NOT NULL,
  `session_code` varchar(20) NOT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `session_date` date NOT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance_sessions`
--

INSERT INTO `attendance_sessions` (`session_id`, `session_code`, `dept_id`, `session_date`, `created_by`, `expires_at`, `is_active`) VALUES
(1, '7R6FYNB3', 1, '2026-06-29', 'System Admin', '2026-06-29 12:58:29', 1),
(2, 'YSQUJVPT', 5, '2026-06-30', 'System Admin', '2026-06-30 12:01:33', 1),
(3, 'GA7JFSC2', 1, '2026-07-02', 'System Admin', '2026-07-02 19:15:40', 1),
(4, '5HXZMXT7', 1, '2026-07-06', 'System Admin', '2026-07-06 17:54:58', 1),
(5, 'JS3HS4NF', 1, '2026-07-08', 'System Admin', '2026-07-08 17:32:01', 1),
(6, 'PP2TP9C5', 1, '2026-07-10', 'System Admin', '2026-07-10 21:22:50', 1),
(7, 'KTYLTVZ6', 1, '2026-07-10', 'System Admin', '2026-07-10 21:23:39', 1);

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `dept_id` int(11) NOT NULL,
  `dept_code` varchar(20) NOT NULL,
  `dept_name` varchar(100) NOT NULL,
  `duration_years` int(11) DEFAULT 2,
  `total_semesters` int(11) DEFAULT 4
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`dept_id`, `dept_code`, `dept_name`, `duration_years`, `total_semesters`) VALUES
(1, 'IT', 'Information Technology', 2, 4),
(2, 'ENG', 'English', 2, 4),
(3, 'THM', 'Tourism & Hospitality Management', 3, 6),
(4, 'MGT', 'Management', 2, 4),
(5, 'ACC', 'Accountancy', 4, 8);

-- --------------------------------------------------------

--
-- Table structure for table `lms_materials`
--

CREATE TABLE `lms_materials` (
  `material_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `material_type` enum('notes','pastpaper','video','link','other') DEFAULT 'notes',
  `link_url` varchar(500) NOT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `semester` int(11) DEFAULT NULL,
  `uploaded_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `file_path` varchar(500) DEFAULT NULL,
  `upload_type` enum('link','file') DEFAULT 'link'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lms_materials`
--

INSERT INTO `lms_materials` (`material_id`, `title`, `description`, `material_type`, `link_url`, `dept_id`, `subject_id`, `semester`, `uploaded_by`, `created_at`, `file_path`, `upload_type`) VALUES
(1, 'Data Structure and Algorithem', '                       DSA', 'notes', 'uploads/1783693762024_DSA-JUMAIL.pdf', 1, NULL, 4, 'System Admin', '2026-07-10 14:29:22', NULL, 'link'),
(2, 'Object Oriented Programming', '              OOP Concepts          ', 'notes', 'uploads/1783694000210_OOP-JUMAIL.pdf', 1, NULL, 3, 'System Admin', '2026-07-10 14:33:20', NULL, 'link'),
(3, 'Operating System', '               Model Paper', 'pastpaper', 'uploads/1783695243044_HNDIT3052_Model_Paper-OS.pdf', 1, NULL, 3, 'System Admin', '2026-07-10 14:54:04', NULL, 'link'),
(4, 'Obeject Oriented Programming', '            OOP 2023', 'pastpaper', 'uploads/1783695354179_2023_-_OOP.pdf', 1, NULL, 3, 'System Admin', '2026-07-10 14:55:54', NULL, 'link'),
(5, 'Data Structures and Algorithm', '        DSA                ', 'notes', 'uploads/1783695891582_DSA_-__JUMAIL-0039_.pdf', 1, NULL, 3, 'System Admin', '2026-07-10 15:04:51', NULL, 'link'),
(6, 'Information and Computer Security', 'ICS                        ', 'pastpaper', 'uploads/1783696967641_Information_and_Computer_Security_-_JUMAIL.pdf', 1, NULL, 3, 'System Admin', '2026-07-10 15:22:47', NULL, 'link'),
(7, 'Database Management System', 'DBMS                        ', 'notes', 'uploads/1783758077814_DBMS_-__JUMAIL-0039_.pdf', 1, NULL, 3, 'System Admin', '2026-07-11 08:21:18', NULL, 'link'),
(8, 'Statistics', '                        Statics', 'notes', 'uploads/1783758171944_Statistics_-__JUMAIL-0039_.pdf', 1, NULL, 3, 'System Admin', '2026-07-11 08:22:52', NULL, 'link'),
(9, 'Enterprise Architecture', '          ER              ', 'notes', 'uploads/1783758283945_EA_-_JUMAIL.pdf', 1, NULL, 4, 'System Admin', '2026-07-11 08:24:44', NULL, 'link'),
(10, 'Software Engineering', 'SE                 ', 'notes', 'uploads/1783758448754_SE_-_JUMAIL.pdf', 1, NULL, 4, 'System Admin', '2026-07-11 08:27:28', NULL, 'link'),
(11, 'Software Engeeniring', '                        2022 SE', 'pastpaper', 'uploads/1783758505283_Software_Engineering-2022.pdf', 1, NULL, 4, 'System Admin', '2026-07-11 08:28:25', NULL, 'link'),
(12, 'Software Quality Assurance', '      SQA           ', 'notes', 'uploads/1783758564638_SQA_-_JUMAIL.pdf', 1, NULL, 4, 'System Admin', '2026-07-11 08:29:24', NULL, 'link'),
(13, 'Software Quality Assurance', 'SQA 2022                        ', 'notes', 'uploads/1783758669606_Software_Quality_Assurance-2022.pdf', 1, NULL, 4, 'System Admin', '2026-07-11 08:31:09', NULL, 'link'),
(14, 'Proffessional World', '                     PW 2022   ', 'pastpaper', 'uploads/1783758744131_Professional_World-2022.pdf', 1, NULL, 4, 'System Admin', '2026-07-11 08:32:24', NULL, 'link'),
(15, 'Statistics', '                        2021', 'pastpaper', 'uploads/1783758928293_Statistics_for_IT_-_2021.pdf', 1, NULL, 3, 'System Admin', '2026-07-11 08:35:28', NULL, 'link'),
(16, 'Web design', '  Past Paper Discussion  ', 'video', 'https://youtu.be/rf1avJcA7ms?si=eynpbrbGyP5LU1j4', 1, NULL, 1, 'System Admin', '2026-07-11 08:45:11', NULL, 'link'),
(17, 'DSA', 'paper Discussion                        ', 'video', 'https://youtu.be/0exxkpaXiQs?si=sRR34Kb0z1nohBqQ', 1, NULL, 3, 'System Admin', '2026-07-11 08:47:27', NULL, 'link'),
(18, 'Writing Skils', '    Paper Discussion               ', 'video', 'https://youtu.be/LAvmBU3GZbU?si=0jecEcZZ4JgPl9Ze', 2, NULL, 1, 'System Admin', '2026-07-11 08:50:15', NULL, 'link'),
(19, 'Financial Accounting', ' Paper Discussion            ', 'video', 'https://youtu.be/g2ersScbi-g?si=DvKrgnuNcydpnYwd', 5, NULL, 1, 'System Admin', '2026-07-11 08:53:12', NULL, 'link'),
(20, 'Principals Of Management', '    Paper Discussion           ', 'video', 'https://youtu.be/ljaZiaiIKeU?si=uv_h2ddFrLgTsZe2', 4, NULL, 1, 'System Admin', '2026-07-11 08:55:58', NULL, 'link'),
(21, 'Information Technology inTHM', '                 Lesson Summary', 'video', 'https://youtu.be/F-1dTWosAxs?si=OKt1o_5D9QOC-WH5', 3, NULL, 1, 'System Admin', '2026-07-11 09:00:03', NULL, 'link'),
(22, 'Department of a Hotel', ' Lesson 06', 'notes', 'uploads/1783788237479_06._Departments_of_a_Hotel.pptx', 3, NULL, 2, 'System Admin', '2026-07-11 16:43:59', NULL, 'link'),
(23, 'Legal Environment of THM', '                        2022 Past Paper', 'pastpaper', 'uploads/1783788338458_Low_2022.pdf', 3, NULL, 2, 'System Admin', '2026-07-11 16:45:38', NULL, 'link'),
(24, 'National & Regional Tourism Planning', ' Lesson 05', 'notes', 'uploads/1783788446882_05._NATIONAL___REGIONAL_TOURISM_PLANNING.pptx', 3, NULL, 2, 'System Admin', '2026-07-11 16:47:26', NULL, 'link'),
(25, 'Low', '       2022                 ', 'pastpaper', 'uploads/1783788555433_Low_2022.pdf', 3, NULL, 2, 'System Admin', '2026-07-11 16:49:15', NULL, 'link');

-- --------------------------------------------------------

--
-- Table structure for table `marks`
--

CREATE TABLE `marks` (
  `mark_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `grade` varchar(10) DEFAULT NULL,
  `gpa_points` decimal(3,2) DEFAULT NULL,
  `exam_year` year(4) DEFAULT NULL,
  `semester` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `marks`
--

INSERT INTO `marks` (`mark_id`, `student_id`, `subject_id`, `grade`, `gpa_points`, `exam_year`, `semester`, `created_at`) VALUES
(1, 2, 5, 'A', 4.00, '2026', 1, '2026-06-30 06:35:50'),
(2, 2, 4, 'C-', 1.70, '2026', 1, '2026-06-30 06:35:52'),
(3, 2, 29, 'B-', 2.70, '2026', 1, '2026-06-30 06:35:52'),
(4, 2, 30, 'A-', 3.70, '2026', 1, '2026-06-30 06:35:52'),
(5, 2, 1, 'C+', 2.30, '2026', 1, '2026-06-30 06:35:53'),
(6, 2, 3, 'B', 3.00, '2026', 1, '2026-06-30 06:35:53'),
(7, 2, 28, 'B', 3.00, '2026', 1, '2026-06-30 06:35:53'),
(8, 2, 2, 'A-', 3.70, '2026', 1, '2026-06-30 06:35:53'),
(9, 2, 21, 'B+', 3.30, '2026', 1, '2026-06-30 06:35:53'),
(10, 46, 5, 'A-', 3.70, '2026', 1, '2026-07-02 17:26:57'),
(11, 46, 4, 'C+', 2.30, '2026', 1, '2026-07-02 17:26:57'),
(12, 46, 29, '', -1.00, '2026', 1, '2026-07-02 17:26:57'),
(13, 46, 30, 'A-', 3.70, '2026', 1, '2026-07-02 17:27:00'),
(14, 46, 1, 'B-', 2.70, '2026', 1, '2026-07-02 17:27:00'),
(15, 46, 3, 'C-', 1.70, '2026', 1, '2026-07-02 17:27:00'),
(16, 46, 28, 'E', 0.00, '2026', 1, '2026-07-02 17:27:00'),
(17, 46, 2, 'B-', 2.70, '2026', 1, '2026-07-02 17:27:00'),
(18, 46, 21, 'B+', 3.30, '2026', 1, '2026-07-02 17:27:00'),
(19, 60, 5, 'A', 4.00, '2026', 1, '2026-07-10 16:08:28'),
(20, 60, 4, 'B+', 3.30, '2026', 1, '2026-07-10 16:08:30'),
(21, 60, 29, 'B', 3.00, '2026', 1, '2026-07-10 16:08:30'),
(22, 60, 30, 'B+', 3.30, '2026', 1, '2026-07-10 16:08:30'),
(23, 60, 1, 'B+', 3.30, '2026', 1, '2026-07-10 16:08:30'),
(24, 60, 3, 'B-', 2.70, '2026', 1, '2026-07-10 16:08:30'),
(25, 60, 28, 'B', 3.00, '2026', 1, '2026-07-10 16:08:30'),
(26, 60, 2, 'C+', 2.30, '2026', 1, '2026-07-10 16:08:30'),
(27, 60, 21, 'A', 4.00, '2026', 1, '2026-07-10 16:08:31'),
(28, 61, 5, 'A', 4.00, '2026', 1, '2026-07-11 13:43:32'),
(29, 61, 4, 'A-', 3.70, '2026', 1, '2026-07-11 13:43:32'),
(30, 61, 29, 'B+', 3.30, '2026', 1, '2026-07-11 13:43:32'),
(31, 61, 30, 'C', 2.00, '2026', 1, '2026-07-11 13:43:32'),
(32, 61, 1, 'A', 4.00, '2026', 1, '2026-07-11 13:43:32'),
(33, 61, 3, 'B', 3.00, '2026', 1, '2026-07-11 13:43:32'),
(34, 61, 28, 'A', 4.00, '2026', 1, '2026-07-11 13:43:32'),
(35, 61, 2, 'B+', 3.30, '2026', 1, '2026-07-11 13:43:33'),
(36, 61, 21, 'B-', 2.70, '2026', 1, '2026-07-11 13:43:33'),
(37, 57, 5, 'A-', 3.70, '2026', 1, '2026-07-11 16:20:47'),
(38, 57, 4, 'A-', 3.70, '2026', 1, '2026-07-11 16:20:53'),
(39, 57, 29, 'B-', 2.70, '2026', 1, '2026-07-11 16:20:54'),
(40, 57, 30, 'A-', 3.70, '2026', 1, '2026-07-11 16:20:54'),
(41, 57, 1, 'B', 3.00, '2026', 1, '2026-07-11 16:20:55'),
(42, 57, 3, 'B', 3.00, '2026', 1, '2026-07-11 16:20:55'),
(43, 57, 28, 'B-', 2.70, '2026', 1, '2026-07-11 16:20:55'),
(44, 57, 2, 'B+', 3.30, '2026', 1, '2026-07-11 16:20:55'),
(45, 57, 21, 'A', 4.00, '2026', 1, '2026-07-11 16:20:55'),
(46, 59, 5, 'A+', 4.00, '2026', 1, '2026-07-11 16:24:38'),
(47, 64, 5, 'B-', 2.70, '2026', 1, '2026-07-11 16:24:38'),
(48, 62, 5, 'B+', 3.30, '2026', 1, '2026-07-11 16:24:38'),
(49, 58, 5, 'B', 3.00, '2026', 1, '2026-07-11 16:24:38'),
(50, 63, 5, 'A', 4.00, '2026', 1, '2026-07-11 16:24:38'),
(51, 69, 5, 'B+', 3.30, '2026', 1, '2026-07-12 14:22:40'),
(52, 69, 4, 'B+', 3.30, '2026', 1, '2026-07-12 14:22:40'),
(53, 69, 29, 'C-', 1.70, '2026', 1, '2026-07-12 14:22:40'),
(54, 69, 30, 'C-', 1.70, '2026', 1, '2026-07-12 14:22:40'),
(55, 69, 1, 'C', 2.00, '2026', 1, '2026-07-12 14:22:40'),
(56, 69, 3, 'C-', 1.70, '2026', 1, '2026-07-12 14:22:40'),
(57, 69, 28, 'NE', 0.00, '2026', 1, '2026-07-12 14:22:40'),
(58, 69, 2, 'C', 2.00, '2026', 1, '2026-07-12 14:22:40'),
(59, 69, 21, 'B', 3.00, '2026', 1, '2026-07-12 14:22:40'),
(60, 71, 3, 'B-', 2.70, '2026', 1, '2026-07-12 14:24:18'),
(61, 72, 3, 'B+', 3.30, '2026', 1, '2026-07-12 14:24:19'),
(62, 66, 3, 'B', 3.00, '2026', 1, '2026-07-12 14:24:19'),
(63, 70, 3, 'C-', 1.70, '2026', 1, '2026-07-12 14:24:19'),
(64, 59, 3, 'A+', 4.00, '2026', 1, '2026-07-12 14:24:19'),
(65, 64, 3, 'C', 2.00, '2026', 1, '2026-07-12 14:24:19'),
(66, 58, 3, 'A-', 3.70, '2026', 1, '2026-07-12 14:24:19'),
(67, 63, 3, 'B-', 2.70, '2026', 1, '2026-07-12 14:24:19'),
(68, 70, 30, 'A+', 4.00, '2026', 1, '2026-07-12 14:25:05'),
(69, 59, 30, 'C', 2.00, '2026', 1, '2026-07-12 14:25:05'),
(70, 64, 30, 'C+', 2.30, '2026', 1, '2026-07-12 14:25:05'),
(71, 62, 30, 'B+', 3.30, '2026', 1, '2026-07-12 14:25:05'),
(72, 58, 30, 'B-', 2.70, '2026', 1, '2026-07-12 14:25:05'),
(73, 63, 30, 'B-', 2.70, '2026', 1, '2026-07-12 14:25:05'),
(74, 58, 4, 'A-', 3.70, '2026', 1, '2026-07-14 06:47:58'),
(75, 58, 1, 'A+', 4.00, '2026', 1, '2026-07-14 06:47:59'),
(76, 58, 28, 'B', 3.00, '2026', 1, '2026-07-14 06:47:59'),
(77, 58, 2, 'C+', 2.30, '2026', 1, '2026-07-14 06:47:59'),
(78, 58, 21, 'C-', 1.70, '2026', 1, '2026-07-14 06:47:59'),
(79, 30, 26, 'B-', 2.70, '2026', 1, '2026-07-14 06:59:53'),
(80, 4, 26, 'C+', 2.30, '2026', 1, '2026-07-14 06:59:53'),
(81, 31, 26, 'A', 4.00, '2026', 1, '2026-07-14 06:59:53'),
(82, 32, 26, 'B+', 3.30, '2026', 1, '2026-07-14 06:59:53'),
(83, 68, 26, 'C', 2.00, '2026', 1, '2026-07-14 06:59:54'),
(84, 38, 26, 'E', 0.00, '2026', 1, '2026-07-14 06:59:55'),
(85, 35, 26, 'C', 2.00, '2026', 1, '2026-07-14 06:59:55'),
(86, 36, 26, 'B-', 2.70, '2026', 1, '2026-07-14 06:59:55'),
(87, 34, 26, 'C', 2.00, '2026', 1, '2026-07-14 06:59:55'),
(88, 33, 26, 'B', 3.00, '2026', 1, '2026-07-14 06:59:55'),
(89, 37, 26, 'C+', 2.30, '2026', 1, '2026-07-14 06:59:55'),
(90, 66, 5, 'A-', 3.70, '2026', 1, '2026-07-14 07:03:15'),
(91, 66, 4, 'C', 2.00, '2026', 1, '2026-07-14 07:03:15'),
(92, 66, 30, 'B+', 3.30, '2026', 1, '2026-07-14 07:03:15'),
(93, 66, 1, 'B+', 3.30, '2026', 1, '2026-07-14 07:03:15'),
(94, 66, 28, 'B-', 2.70, '2026', 1, '2026-07-14 07:03:15'),
(95, 66, 2, 'A-', 3.70, '2026', 1, '2026-07-14 07:03:15'),
(96, 66, 21, 'B-', 2.70, '2026', 1, '2026-07-14 07:03:15');

-- --------------------------------------------------------

--
-- Table structure for table `notices`
--

CREATE TABLE `notices` (
  `notice_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `priority` enum('normal','important','urgent') DEFAULT 'normal',
  `posted_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notices`
--

INSERT INTO `notices` (`notice_id`, `title`, `content`, `dept_id`, `priority`, `posted_by`, `created_at`, `expires_at`) VALUES
(1, 'Exam', 'Exam  will be held in August', NULL, 'urgent', 'System Admin', '2026-07-10 14:45:27', '2026-07-10'),
(2, 'Exam', 'Semester Exam will be held on August', NULL, 'urgent', 'System Admin', '2026-07-11 06:35:24', '2026-07-11'),
(3, 'Exam', 'Semester exam will be held on August', NULL, 'normal', 'System Admin', '2026-07-12 02:33:52', '2026-07-31'),
(4, 'Result', 'Previous semester Exam result released', NULL, 'important', 'System Admin', '2026-07-12 04:46:41', '2026-07-31');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `student_id` int(11) NOT NULL,
  `reg_number` varchar(50) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `year_level` enum('First Year','Second Year') NOT NULL,
  `course_name` varchar(100) DEFAULT NULL,
  `qr_code_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `semester` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`student_id`, `reg_number`, `full_name`, `email`, `phone`, `dept_id`, `year_level`, `course_name`, `qr_code_path`, `created_at`, `semester`) VALUES
(2, 'BAD/IT/2324/F/002', 'Geethmi Iresha', 'geeth12@gmail.com', '0704567893', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_2_BAD_IT_2324_F_002.png', '2026-06-27 10:38:51', 1),
(3, 'BAD/IT/2324/F/004', 'Lihini Mindana', 'lihini@gmail.com', '0785678934', 2, 'Second Year', 'HNDE', 'qrcodes/QR_3_BAD_IT_2324_F_004.png', '2026-06-27 10:42:33', 1),
(4, 'BAD/IT/2324/F/005', 'Hirushani Marasinha', 'hiru@123gmail.com', '0769834527', 3, 'First Year', 'HNDTHM', 'qrcodes/QR_4_BAD_IT_2324_F_005.png', '2026-06-28 03:50:50', 1),
(5, 'BAD/IT/2324/F/006', 'Nethmi Ahinsa', 'neth1234@gmail.com', '0757834527', 5, 'First Year', 'HNDA', 'qrcodes/QR_5_BAD_IT_2324_F_006.png', '2026-06-28 03:52:45', 1),
(6, 'BAD/IT/2324/F/007', 'Sachintha Sanjula', 'sach123@gmail.com', '0782657023', 4, 'Second Year', 'HNDM', 'qrcodes/QR_6_BAD_IT_2324_F_007.png', '2026-06-28 03:54:21', 1),
(7, 'BAD/IT/2324/F/008', 'Pawani Perara', 'pawani@gmail.com', '0768934256', 4, 'First Year', 'HNDM', 'qrcodes/QR_7_BAD_IT_2324_F_008.png', '2026-06-28 03:55:14', 1),
(8, 'BAD/IT/2324/F/009', 'R.M.S.S.Ranasinghe', 'pawani@gmail.com', '0768934256', 5, 'First Year', 'HNDA', 'qrcodes/QR_8_BAD_IT_2324_F_009.png', '2026-06-28 14:33:30', 1),
(9, 'BAD/IT/2324/F/010', 'Vidusha Methmal', 'vidusha@gmail.com', '0782426416', 5, 'First Year', 'HNDA', 'qrcodes/QR_9_BAD_IT_2324_F_010.png', '2026-06-28 14:37:25', 1),
(10, 'BAD/IT/2324/F/011', 'Yasiru Rashmin', 'Rashmin@gmail.vom', '077 2345167', 5, 'First Year', 'HNDA', NULL, '2026-06-28 14:38:35', 1),
(11, 'BAD/IT/2324/F/012', 'Imesh Sadamith', 'Sadamith@gmail.vom', '0786543214', 5, 'First Year', 'HNDA', 'qrcodes/QR_11_BAD_IT_2324_F_012.png', '2026-06-28 14:39:40', 1),
(12, 'BAD/IT/2324/F/013', 'Sithija Senehes', 'Senehas@gmail.com', '0785643245', 5, 'First Year', 'HNDA', 'qrcodes/QR_12_BAD_IT_2324_F_013.png', '2026-06-28 14:40:35', 1),
(13, 'BAD/IT/2324/F/014', 'Sakuntha Miyuru', 'Miyuru@gamil.com', '0786542678', 5, 'First Year', 'HNDA', 'qrcodes/QR_13_BAD_IT_2324_F_014.png', '2026-06-28 14:42:10', 1),
(14, 'BAD/IT/2324/F013', 'Sahan Bandara', 'Bandara@gmail.com', '0785678672', 5, 'First Year', 'HNDA', 'qrcodes/QR_14_BAD_IT_2324_F013.png', '2026-06-28 14:43:41', 1),
(15, 'BAD/DA/2324/F/015', 'Sethmini Kaushlya', 'Kaushalya@gmail.com', '0786543215', 5, 'Second Year', 'HNDA', NULL, '2026-06-28 14:46:14', 1),
(16, 'BAD/DA/2324/F/016', 'Gashini Dinuththara', 'Gashini@gmail.com', '0756542314', 5, 'Second Year', 'HNDA', 'qrcodes/QR_16_BAD_DA_2324_F_016.png', '2026-06-28 14:47:23', 1),
(17, 'BAD/DA/2324/F/017', 'Dewmi Uththara', 'Dewmi@gmail.com', '0756425142', 5, 'Second Year', 'HNDA', 'qrcodes/QR_17_BAD_DA_2324_F_017.png', '2026-06-28 14:48:26', 1),
(18, 'BAD/DA/2324/F/018', 'Umayanga Kaushalya', 'Umayanga@gmail.com', '0783524315', 5, 'Second Year', 'HNDA', NULL, '2026-06-28 14:49:39', 1),
(19, 'BAD/DA/2324/F/019', 'Sarath Wicramasinghe', 'Sarath@gmail.com', '0784535353', 5, 'Second Year', 'HNDA', NULL, '2026-06-28 14:50:48', 1),
(20, 'BAD/EN/2324/F/020', 'Vishmi Yuwanika', 'Vishmi@gmail.com', '078654253', 2, 'First Year', 'HNDE', 'qrcodes/QR_20_BAD_EN_2324_F_020.png', '2026-06-28 16:08:25', 1),
(21, 'BAD/EN/2324/F/021', 'Tharushi Gimsarani', 'Tharushi@gmail.com', '0786352726', 2, 'First Year', 'HNDE', 'qrcodes/QR_21_BAD_EN_2324_F_021.png', '2026-06-28 16:09:59', 1),
(22, 'BAD/EN/2324/F/022', 'Kavindya Sathsarani', 'Kavindya@gmail.com', '0786464645', 2, 'First Year', 'HNDE', 'qrcodes/QR_22_BAD_EN_2324_F_022.png', '2026-06-28 16:11:13', 1),
(24, 'BAD/EN/2324/F/023', 'Kavindya Sathsarani', 'Kavindya@gmail.com', '0785463728', 2, 'First Year', 'HNDE', 'qrcodes/QR_24_BAD_EN_2324_F_023.png', '2026-06-28 16:14:28', 1),
(25, 'BAD/EN/2324/F/024', 'Pamodya Nethmi', 'Pamodya@gmail.com', '0782657023', 2, 'First Year', 'HNDE', 'qrcodes/QR_25_BAD_EN_2324_F_024.png', '2026-06-28 16:15:19', 1),
(26, 'BAD/EN/2324/F/025', 'Kalpani Kawindya', 'Kalpani@gmail.com', '0756353536', 2, 'First Year', 'HNDE', 'qrcodes/QR_26_BAD_EN_2324_F_025.png', '2026-06-28 16:16:11', 1),
(27, 'BAD/EN/2324/F/026', 'Samadi Layanga', 'Samadi@gmail.com', '0786453643', 2, 'Second Year', 'HNDE', 'qrcodes/QR_27_BAD_EN_2324_F_026.png', '2026-06-28 16:17:02', 1),
(28, 'BAD/EN/2324/F/027', 'Tharusha Dilshan', 'Tharusha@gmail.com', '0785342314', 2, 'Second Year', 'HNDE', 'qrcodes/QR_28_BAD_EN_2324_F_027.png', '2026-06-28 16:18:14', 1),
(29, 'BAD/EN/2324/F/028', 'Theekshana Adithya', 'Theekshana@gmail.com', '0765435363', 2, 'Second Year', 'HNDE', 'qrcodes/QR_29_BAD_EN_2324_F_028.png', '2026-06-28 16:21:36', 1),
(30, 'BAD/EN/2324/F/029', 'Chamika Sathsara', 'Chamika@gmail.com', '078534263', 3, 'First Year', 'HNDTHM', 'qrcodes/QR_30_BAD_EN_2324_F_029.png', '2026-06-28 16:22:52', 1),
(31, 'BAD/THM/2324/F/030', 'Kavindu Sathsara', 'Kavindu@gmail.com', '0786576575', 3, 'First Year', 'HNDTHM', 'qrcodes/QR_31_BAD_THM_2324_F_030.png', '2026-06-28 16:25:09', 1),
(32, 'BAD/THM/2324/F/031', 'Mangala Ptiyanthika', 'Mangala@gmail.com', '0765466645', 3, 'First Year', 'HNDTHM', 'qrcodes/QR_32_BAD_THM_2324_F_031.png', '2026-06-28 16:26:08', 1),
(33, 'BAD/THM/2324/F/032', 'Mallika Thennakon', 'Mallika@gmail.com', '0786574536', 3, 'Second Year', 'HNDTHM', 'qrcodes/QR_33_BAD_THM_2324_F_032.png', '2026-06-28 16:28:24', 1),
(34, 'BAD/THM/2324/F/033', 'Maleesha Sewwandi', 'Maleesha@gmail.com', '0876543234', 3, 'Second Year', 'HNDTHM', 'qrcodes/QR_34_BAD_THM_2324_F_033.png', '2026-06-28 16:29:32', 1),
(35, 'BAD/THM/2324/F/034', 'Chamod Nethmina', 'Chamod@gmail.com', '0786546353', 3, 'Second Year', 'HNDTHM', 'qrcodes/QR_35_BAD_THM_2324_F_034.png', '2026-06-28 16:30:34', 1),
(36, 'BAD/THM/2324/F/035', 'Imesha Manohari', 'Imesha@gmail.com', '0786756456', 3, 'Second Year', 'HNDTHM', 'qrcodes/QR_36_BAD_THM_2324_F_035.png', '2026-06-28 16:31:35', 1),
(37, 'BAD/THM/2324/F/036', 'Thanuja Kuree', 'Thanuja@gmail.com', '0786756567', 3, 'Second Year', 'HNDTHM', 'qrcodes/QR_37_BAD_THM_2324_F_036.png', '2026-06-28 16:32:37', 1),
(38, 'BAD/THM/2324/F/037', 'Ashan Dimantha', 'Ashan@gmail.com', '0786545324', 3, 'Second Year', 'HNDTHM', 'qrcodes/QR_38_BAD_THM_2324_F_037.png', '2026-06-28 16:34:22', 1),
(46, 'BAD/IT/2324/F/32', 'Ishani Umayanthi', 'ishani@gmail.com', '0768934563', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_46_BAD_IT_2324_F_32.png', '2026-06-30 13:39:09', 1),
(47, 'BAD/MNG/2324/F/034', 'Sachini Aradhana', 'sach123#@gmail.com', '0768945032', 4, 'First Year', 'HNDM', 'qrcodes/QR_47_BAD_MNG_2324_F_034.png', '2026-06-30 13:43:13', 1),
(48, 'BAD/MNG/2324/F/035', 'Nethmi Nawodya', 'nethmi@gmail.com', '0786543532', 4, 'First Year', 'HNDM', 'qrcodes/QR_48_BAD_MNG_2324_F_035.png', '2026-06-30 13:44:21', 1),
(49, 'BAD/MNG/2324/F/36', 'Dulaj Lakshitha', 'dulaj123@gmail.com', '0765798432', 4, 'Second Year', 'HNDM', 'qrcodes/QR_49_BAD_MNG_2324_F_36.png', '2026-06-30 13:45:33', 1),
(50, 'BAD/MNG/2324/F/038', 'Kasindu Sankalpa', 'kasi345@gmail.com', '0754376589', 4, 'First Year', 'HNDM', 'qrcodes/QR_50_BAD_MNG_2324_F_038.png', '2026-06-30 13:47:03', 1),
(51, 'BAD/MNG/2324/F/039', 'Nethmi Rumalka', 'nethmi132@gmail.com', '0768934526', 4, 'Second Year', 'HNDM', 'qrcodes/QR_51_BAD_MNG_2324_F_039.png', '2026-06-30 13:48:35', 1),
(52, 'BAD/MNG/2324/F/040', 'Sandun Frenando', 'sadun345@gmail.com', '0876954632', 4, 'First Year', 'HNDM', 'qrcodes/QR_52_BAD_MNG_2324_F_040.png', '2026-06-30 13:51:03', 1),
(53, 'BA/MNG/2324/F/42', 'Lasith Charuka', 'lasith@gmail.com', '0786954321', 4, 'Second Year', 'HNDM', 'qrcodes/QR_53_BA_MNG_2324_F_42.png', '2026-06-30 13:55:59', 1),
(54, 'BAD/MNG/2324F/43', 'Saman Kumara', 'saman@gmail.com', '0765983421', 4, 'First Year', 'HNDM', 'qrcodes/QR_54_BAD_MNG_2324F_43.png', '2026-06-30 13:57:20', 1),
(57, 'BAD/IT/2526/S/003', 'Sujan Menaka', 'sujanmenaka@gmail.com', '0786954320', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_57_BAD_IT_2526_S_003.png', '2026-07-10 15:41:08', 1),
(58, 'BAD/IT/2526/S/004', 'Theekshana Adithya', 'theekshana@gmail.com', '0786954320', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_58_BAD_IT_2526_S_004.png', '2026-07-10 15:42:07', 1),
(59, 'BAD/IT/2526/S/005', 'Kavindya Sathsarani', 'kavi1234@gmail.com', '07546879324', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_59_BAD_IT_2526_S_005.png', '2026-07-10 15:42:58', 1),
(60, 'BAD/IT/2526/S/006', 'Hashini Suwanika', 'hashinisuwanika@gmail.com', '0782867904', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_60_BAD_IT_2526_S_006.png', '2026-07-10 15:43:46', 1),
(61, 'BAD/IT/2526/S/007', 'Dilki Tharushika', 'dilkitharushika@gmail.com', '07654987604', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_61_BAD_IT_2526_S_007.png', '2026-07-10 15:44:27', 1),
(62, 'BAD/IT/2526/S/008', 'Subhashini', 'subha1234@gmail.com', '0765432187', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_62_BAD_IT_2526_S_008.png', '2026-07-10 15:45:16', 1),
(63, 'BAD/IT/2526/S/009', 'Vidhurshini', 'vidhu123@gmail.com', '0708974532', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_63_BAD_IT_2526_S_009.png', '2026-07-10 15:45:49', 1),
(64, 'BAD/IT/2526/S/010', 'Poojani Sanjana', 'poojani456@gmail.com', '0765437896', 1, 'Second Year', 'HNDIT', 'qrcodes/QR_64_BAD_IT_2526_S_010.png', '2026-07-10 15:46:36', 1),
(65, 'BAD/MGT/2526/F/007', 'Tharuki Ahinsa', 'tharuki123@gmail.com', '0786549342', 4, 'First Year', 'HNDM', NULL, '2026-07-12 02:23:18', 1),
(66, 'BAD/IT/2526/F/001', 'Thisara Sandeepani', 'thisara@gmail.com', '0756894321', 1, 'First Year', 'HNDIT', NULL, '2026-07-12 14:08:19', 1),
(67, 'BAD/ENG/2526/S/005', 'Pethum Thathsara', 'pethum1234@gmail.com', '0785467432', 2, 'Second Year', 'HNDE', NULL, '2026-07-12 14:09:23', 1),
(68, 'BAD/THM/2526/F/005', 'Senuri Nikeshala', 'senu123@gmail.com', '0782345678', 3, 'First Year', 'HNDTHM', NULL, '2026-07-12 14:10:17', 1),
(69, 'BAD/IT/2526/F/002', 'Methula Sanketh', 'methu1234@gmail.com', '0764896342', 1, 'First Year', 'HNDIT', NULL, '2026-07-12 14:11:57', 1),
(70, 'BAD/IT/2526/F/003', 'Tinura Basith', 'tinura@gmail.com', '0768943217', 1, 'First Year', 'HNDIT', NULL, '2026-07-12 14:12:46', 1),
(71, 'BAD/IT/2526/F/004', 'Jinuli Dahamsa', 'jinulidahamsa@gmail.com', '0783452167', 1, 'First Year', 'HNDIT', NULL, '2026-07-12 14:13:41', 1),
(72, 'BAD/IT/2526/F/005', 'Raween Tharuka', 'raweentharuka@gmail.com', '0709845673', 1, 'First Year', 'HNDIT', NULL, '2026-07-12 14:16:14', 1),
(73, 'BAD/IT/2526/F/006', 'Dedunu Sandeshani', 'dedunu1234@gmail.com', '076895643', 1, 'First Year', 'HNDIT', NULL, '2026-07-13 11:51:58', 1),
(74, 'BAD/IT/2526/F/007', 'Chamodi Prathibhani', 'chamodi123@gmail.com', '0768975432', 1, 'First Year', 'HNDIT', 'qrcodes/QR_74_BAD_IT_2526_F_007.png', '2026-07-13 12:07:29', 1);

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `subject_id` int(11) NOT NULL,
  `dept_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `subject_name` varchar(150) NOT NULL,
  `credit_hours` int(11) DEFAULT 3
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`subject_id`, `dept_id`, `semester`, `subject_name`, `credit_hours`) VALUES
(1, 1, 1, 'IT Fundamentals', 3),
(2, 1, 1, 'Programming Fundamentals', 4),
(3, 1, 1, 'Mathematics for IT', 3),
(4, 1, 1, 'Database Management Systems', 4),
(5, 1, 1, 'Communication Skills', 2),
(6, 1, 2, 'Software Development', 4),
(7, 1, 2, 'Principles Of User Interface Design', 3),
(8, 1, 2, 'System Analysis and Design', 3),
(9, 1, 2, 'Fundamentals Of Programming', 3),
(10, 1, 2, 'Data Communication and Computer Network', 2),
(11, 1, 3, 'Advanced Programming', 4),
(12, 1, 3, 'Software Engineering', 3),
(13, 1, 3, 'System Analysis and Design', 3),
(14, 1, 3, 'Mobile Application Development', 3),
(15, 1, 3, 'Information Security', 3),
(16, 1, 4, 'IT Project Management', 3),
(17, 1, 4, 'Software Engineering', 3),
(18, 1, 4, 'Professional World', 3),
(19, 1, 4, 'Software Quality Assurance', 6),
(20, 1, 4, 'Programming Individual Project', 3),
(21, 1, 1, 'Web Design', 3),
(22, 3, 1, 'Principales  of Management', 2),
(23, 3, 1, 'Tourism Priciples and Practices', 3),
(24, 3, 1, 'Tourism Economics', 3),
(25, 3, 1, 'Sri Lankan Studies', 3),
(26, 3, 1, 'ICT', 3),
(27, 3, 1, 'Business English', 3),
(28, 1, 1, 'Mobile Application Development', 3),
(29, 1, 4, 'Enterprice Architecture', 3),
(30, 1, 1, 'ICT Project', 3),
(31, 1, 2, 'Technical Writing', 3),
(33, 1, 2, 'Human Value and Professional Ethics', 3),
(34, 1, 2, 'ICT Project', 3),
(35, 2, 2, 'English grammar and vocabulary in context', 3),
(36, 2, 2, 'Listening Skills in English Level', 3),
(37, 2, 2, 'Speking', 3),
(38, 2, 2, 'Reading', 3),
(39, 2, 2, 'Writing', 3),
(40, 2, 2, 'English Literature', 3),
(41, 2, 2, 'Technology Assisted Language', 3),
(42, 2, 2, 'Language and Mind', 3),
(43, 2, 2, 'Human Value and Professionalism', 2),
(44, 2, 4, 'Presentation Skills', 3),
(45, 2, 4, 'ReadingSkills for Academic & Professional Contexts', 3),
(46, 2, 4, 'Writing Skills for Academic & Professional Contexts', 3),
(47, 2, 4, 'Sri Lankan Literature in English', 3),
(48, 2, 4, 'Key Concepts in Educational philosophyy', 3),
(49, 2, 4, 'Key Concepts in Educational Psychology', 3),
(50, 2, 4, 'Trends & Practicesvin teaching English', 3),
(51, 2, 4, 'Testing & Assessment in Language Class room', 3),
(52, 2, 4, 'Teaching Project', 3),
(53, 3, 2, 'Department of a Hotel', 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `role` enum('admin','lecturer','student') DEFAULT 'admin',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `dept_id` int(11) DEFAULT NULL,
  `student_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `full_name`, `role`, `created_at`, `dept_id`, `student_id`) VALUES
(1, 'admin', 'admin123', 'System Admin', 'admin', '2026-06-27 03:56:47', NULL, NULL),
(2, 'it_lecturer', 'lecturer123', 'IT Department Lecturer', 'lecturer', '2026-07-02 12:49:50', 1, NULL),
(3, 'eng_lecturer', 'lecturer123', 'English Lecturer', 'lecturer', '2026-07-02 12:49:50', 2, NULL),
(4, 'thm_lecturer', 'lecturer123', 'THM Lecturer', 'lecturer', '2026-07-02 12:49:50', 3, NULL),
(5, 'mgt_lecturer', 'lecturer123', 'Management Lecturer', 'lecturer', '2026-07-02 12:49:50', 4, NULL),
(6, 'acc_lecturer', 'lecturer123', 'Accountancy Lecturer', 'lecturer', '2026-07-02 12:49:50', 5, NULL),
(8, 'sakuntha', 'sakuntha123', 'Sakuntha Miyuru', 'student', '2026-07-02 13:25:12', NULL, 13);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`att_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `dept_id` (`dept_id`);

--
-- Indexes for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD UNIQUE KEY `session_code` (`session_code`),
  ADD KEY `dept_id` (`dept_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`dept_id`);

--
-- Indexes for table `lms_materials`
--
ALTER TABLE `lms_materials`
  ADD PRIMARY KEY (`material_id`),
  ADD KEY `dept_id` (`dept_id`),
  ADD KEY `subject_id` (`subject_id`);

--
-- Indexes for table `marks`
--
ALTER TABLE `marks`
  ADD PRIMARY KEY (`mark_id`),
  ADD UNIQUE KEY `unique_mark` (`student_id`,`subject_id`,`exam_year`),
  ADD KEY `subject_id` (`subject_id`);

--
-- Indexes for table `notices`
--
ALTER TABLE `notices`
  ADD PRIMARY KEY (`notice_id`),
  ADD KEY `dept_id` (`dept_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`student_id`),
  ADD UNIQUE KEY `reg_number` (`reg_number`),
  ADD KEY `dept_id` (`dept_id`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`subject_id`),
  ADD KEY `dept_id` (`dept_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `fk_user_dept` (`dept_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `att_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=204;

--
-- AUTO_INCREMENT for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `dept_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `lms_materials`
--
ALTER TABLE `lms_materials`
  MODIFY `material_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `marks`
--
ALTER TABLE `marks`
  MODIFY `mark_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT for table `notices`
--
ALTER TABLE `notices`
  MODIFY `notice_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `student_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`);

--
-- Constraints for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  ADD CONSTRAINT `attendance_sessions_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`);

--
-- Constraints for table `lms_materials`
--
ALTER TABLE `lms_materials`
  ADD CONSTRAINT `lms_materials_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`),
  ADD CONSTRAINT `lms_materials_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`);

--
-- Constraints for table `marks`
--
ALTER TABLE `marks`
  ADD CONSTRAINT `marks_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `marks_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`);

--
-- Constraints for table `notices`
--
ALTER TABLE `notices`
  ADD CONSTRAINT `notices_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`);

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`);

--
-- Constraints for table `subjects`
--
ALTER TABLE `subjects`
  ADD CONSTRAINT `subjects_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_dept` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `auto_mark_absent` ON SCHEDULE EVERY 1 DAY STARTS '2026-07-09 09:20:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    INSERT INTO attendance (student_id, dept_id, att_date, att_time, status)
    SELECT s.student_id, s.dept_id, CURDATE(), '09:15:00', 'Absent'
    FROM students s
    WHERE s.student_id NOT IN (
        SELECT student_id FROM attendance
        WHERE att_date = CURDATE()
    );
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
