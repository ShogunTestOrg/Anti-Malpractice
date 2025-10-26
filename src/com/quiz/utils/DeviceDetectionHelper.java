package com.quiz.utils;

import javax.servlet.http.HttpServletRequest;

public class DeviceDetectionHelper {
    
    /**
     * Detects the device type from user agent
     * @param request HttpServletRequest
     * @return Device type (DESKTOP, MOBILE, TABLET)
     */
    public static String getDeviceType(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        
        if (userAgent == null) {
            return "UNKNOWN";
        }
        
        userAgent = userAgent.toLowerCase();
        
        if (userAgent.contains("mobile") || userAgent.contains("android") || 
            userAgent.contains("iphone")) {
            return "MOBILE";
        } else if (userAgent.contains("tablet") || userAgent.contains("ipad")) {
            return "TABLET";
        } else {
            return "DESKTOP";
        }
    }
    
    /**
     * Gets the browser name from user agent
     * @param request HttpServletRequest
     * @return Browser name
     */
    public static String getBrowserName(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        
        if (userAgent == null) {
            return "UNKNOWN";
        }
        
        userAgent = userAgent.toLowerCase();
        
        if (userAgent.contains("edg")) {
            return "Microsoft Edge";
        } else if (userAgent.contains("chrome")) {
            return "Google Chrome";
        } else if (userAgent.contains("firefox")) {
            return "Mozilla Firefox";
        } else if (userAgent.contains("safari")) {
            return "Safari";
        } else if (userAgent.contains("opera") || userAgent.contains("opr")) {
            return "Opera";
        } else {
            return "UNKNOWN";
        }
    }
    
    /**
     * Gets the operating system from user agent
     * @param request HttpServletRequest
     * @return Operating system name
     */
    public static String getOperatingSystem(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        
        if (userAgent == null) {
            return "UNKNOWN";
        }
        
        userAgent = userAgent.toLowerCase();
        
        if (userAgent.contains("windows")) {
            return "Windows";
        } else if (userAgent.contains("mac")) {
            return "Mac OS";
        } else if (userAgent.contains("linux")) {
            return "Linux";
        } else if (userAgent.contains("android")) {
            return "Android";
        } else if (userAgent.contains("iphone") || userAgent.contains("ipad")) {
            return "iOS";
        } else {
            return "UNKNOWN";
        }
    }
    
    /**
     * Gets the client IP address
     * @param request HttpServletRequest
     * @return IP address
     */
    public static String getClientIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        
        return ip;
    }
    
    /**
     * Gets device fingerprint (combination of device info)
     * @param request HttpServletRequest
     * @return Device fingerprint string
     */
    public static String getDeviceFingerprint(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        String acceptLanguage = request.getHeader("Accept-Language");
        String acceptEncoding = request.getHeader("Accept-Encoding");
        String ip = getClientIpAddress(request);
        
        return String.format("%s|%s|%s|%s", userAgent, acceptLanguage, acceptEncoding, ip);
    }
}
