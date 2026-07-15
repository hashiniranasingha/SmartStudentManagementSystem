package com.sms.util;

import javax.servlet.http.HttpSession;

public class RoleCheck {

    public static boolean isAdmin(HttpSession session){
        return "admin".equals(session.getAttribute("userRole"));
    }

    public static boolean isLecturer(HttpSession session){
        return "lecturer".equals(session.getAttribute("userRole"));
    }

    public static boolean isStudent(HttpSession session){
        return "student".equals(session.getAttribute("userRole"));
    }

    public static boolean isAdminOrLecturer(HttpSession session){
        String role = (String) session.getAttribute("userRole");
        return "admin".equals(role) || "lecturer".equals(role);
    }

    public static boolean isLoggedIn(HttpSession session){
        return session.getAttribute("loggedUser") != null;
    }

    public static String getDeptId(HttpSession session){
        Object d = session.getAttribute("userDeptId");
        return d != null ? d.toString() : "";
    }

    public static String getDeptCode(HttpSession session){
        Object d = session.getAttribute("userDeptCode");
        return d != null ? d.toString() : "";
    }
}