/******************************************************************
 * File:        OrgDC.java
 * Created by:  Dave Reynolds
 * Created on:  16 May 2014
 * 
 * (c) Copyright 2014, Epimorphics Limited
 *
 *****************************************************************/

package com.epimorphics.orgdc;

import java.io.File;

import org.apache.catalina.startup.Tomcat;

/**
 * Embeedd tomcat running for development.
 * 
 * @author <a href="mailto:dave@epimorphics.com">Dave Reynolds</a>
 */
public class OrgDC {
    public static void main(String[] args) throws Exception {
        String root = "src/main/webapp";

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(8080);

        tomcat.setBaseDir(".");

        String contextPath = "/";

        File rootF = new File(root);
        if (!rootF.exists()) {
            rootF = new File(".");
        }
        if (!rootF.exists()) {
            System.err.println("Can't find root app: " + root);
            System.exit(1);
        }

        tomcat.addWebapp(contextPath,  rootF.getAbsolutePath());
//        org.apache.catalina.Context context = tomcat.addWebapp(contextPath,  rootF.getAbsolutePath());
//        context.setConfigFile(new URL("file:src/main/webapp/META-INF/context.xml"));

        tomcat.start();
        tomcat.getServer().await();

      }
}
