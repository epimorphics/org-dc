/******************************************************************
 * File:        Endpoints.java
 * Created by:  Dave Reynolds
 * Created on:  16 May 2014
 * 
 * (c) Copyright 2014, Epimorphics Limited
 *
 *****************************************************************/

package com.epimorphics.orgdc.webapi;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.epimorphics.appbase.core.AppConfig;
import com.epimorphics.appbase.tasks.NestedProgressReporter;
import com.epimorphics.appbase.util.TimeStamp;
import com.epimorphics.appbase.webapi.WebApiException;
import com.epimorphics.dclib.framework.ConverterProcess;
import com.epimorphics.dclib.framework.ConverterService;
import com.epimorphics.orgdc.Config;
import com.epimorphics.tasks.ProgressMessage;
import com.epimorphics.tasks.ProgressMonitorReporter;
import com.epimorphics.tasks.SimpleProgressMonitor;
import com.epimorphics.util.FileUtil;
import com.hp.hpl.jena.rdf.model.Model;
import com.sun.jersey.multipart.FormDataBodyPart;
import com.sun.jersey.multipart.FormDataMultiPart;

@Path("/convert")
public class Endpoints {
    static final Logger log = LoggerFactory.getLogger( Endpoints.class );
    
    public static final String FULL_MIME_TURTLE = "text/turtle; charset=UTF-8";
    
    public static final String RELEASE_PARAM  = "release";
    public static final String RELEASE_VAR    = "$versionDate";
    public static final String BASENAME_PARAM = "basename";
    public static final String BASENAME_VAR   = "$basename";
    public static final String JUNIOR_PARAM   = "junior-csv";
    public static final String SENIOR_PARAM   = "senior-csv";
    public static final String DEBUG_PARAM   = "debug";
    public static final String TOP_TEMPLATE   = "top";
    
    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String helloWorld() {
        return "hello from data converter\n";
    }
    
    @POST
    @Consumes({MediaType.MULTIPART_FORM_DATA})
    @Produces({FULL_MIME_TURTLE})
    public Response convert(@Context HttpHeaders hh, FormDataMultiPart multiPart) {
        log.info("Conversion request received");
        String release = getStringValue(multiPart, RELEASE_PARAM);
        if (release == null) {
            log.error( "Missing required parameter: " + RELEASE_PARAM );
            throw new WebApiException(Status.BAD_REQUEST, "Missing required parameter: " + RELEASE_PARAM);
        }
        String basename = getStringValue(multiPart, BASENAME_PARAM);

        InputStream seniorPosts = readFile(multiPart, SENIOR_PARAM);
        if (basename == null) {
            basename = multiPart.getField(SENIOR_PARAM).getContentDisposition().getFileName();
            basename = basename.replaceAll("-?senior", "").replace(".csv", "");
        }
        log.info( String.format("Request accepted %s [%s]", basename, release) );
        
        boolean debug = "true".equalsIgnoreCase( getStringValue(multiPart, DEBUG_PARAM) );
        
        long start = System.currentTimeMillis();
        SimpleProgressMonitor monitor = new SimpleProgressMonitor();
        Model smodel = process(seniorPosts, release, basename, monitor, debug);
        
        InputStream juniorPosts = readFile(multiPart, JUNIOR_PARAM);
        Model jmodel = process(juniorPosts, release, basename, monitor, debug);
        long duration = System.currentTimeMillis() - start;

        Long size = null;
        if (smodel != null && jmodel != null) {
            smodel.add( jmodel );
            size = smodel.size();
        }
        String tracelog = generateTrace(monitor, release, basename, duration, size);
        String tracefile = saveTrace( tracelog );

        if (debug) {
            log.info( tracelog );
        }
        if (size != null) {
            log.info( String.format("Request succceeded: %d triples, %d ms", size, duration) );
            return Response.ok().entity( smodel ).build();
            
        } else {
            log.info( "Conversion failed, see trace: " + tracefile );
            return Response.status(Status.BAD_REQUEST).entity(tracelog).build();
        }
    }   
    
    
    @Path("test")
    @POST
    @Consumes({MediaType.MULTIPART_FORM_DATA})
    @Produces({FULL_MIME_TURTLE})
    public Response test(@Context HttpHeaders hh, FormDataMultiPart multiPart) throws IOException {
        log.info("Test conversion request received");
        InputStream seniorPosts = readFile(multiPart, SENIOR_PARAM);
        System.out.println("Senior posts");
        FileUtil.copyResource(seniorPosts, System.out);
        
        InputStream juniorPosts = readFile(multiPart, JUNIOR_PARAM);
        System.out.println("Junior posts");
        FileUtil.copyResource(juniorPosts, System.out);
        
        return Response.ok().build();
    }    
    
    protected String getStringValue(FormDataMultiPart data, String field) {
        FormDataBodyPart part = data.getField(field);
        if (part == null) {
            return null;
        } else {
            return part.getValue();
        }
    }
    
    protected InputStream readFile(FormDataMultiPart data, String field) {
        FormDataBodyPart part = data.getField(field);
        if (part == null) {
            log.error("Missing required file parameter: " + field);
            throw new WebApiException(Status.BAD_REQUEST, "Missing required file parameter: " + field);
        }
        return part.getValueAs(InputStream.class);
    }
    
    protected Model process(InputStream in, String release, String basename, ProgressMonitorReporter monitor, boolean debug) {
        ConverterService service = AppConfig.getApp().getA(ConverterService.class);
        ConverterProcess proc = service.startConvert(TOP_TEMPLATE, in);
        proc.getEnv().put(RELEASE_VAR, release);
        proc.getEnv().put(BASENAME_VAR, basename);
        proc.setDebug(debug);
        proc.setMessageReporter( new NestedProgressReporter(monitor) );
        if (proc.process()) {
            Model result = proc.getModel();
            result.setNsPrefixes( service.getDataContext().getPrefixes() );
            return proc.getModel();
        } else {
            return null;
        }
    }
    
    protected String saveTrace(String tracelog) {
        try {
            String traceDir = AppConfig.getApp().getA(Config.class).getTraceDir();
            FileUtil.ensureDir(traceDir);
            File trace = new File( new File(traceDir), "trace-" + TimeStamp.makeTimestamp() + ".txt");
            BufferedWriter out = new BufferedWriter( new FileWriter(trace) );
            out.write(tracelog);
            out.close();
            return trace.getPath();
        } catch (Exception e) {
            log.error("Problem writing trace log: ", e);
            return null;
        }
    }
    
    protected String generateTrace(ProgressMonitorReporter monitor, String release, String basename, long duration, Long size) {
        StringBuffer out = new StringBuffer();
        out.append("Trace of processing " + basename + " [" + release + "]\n");
        out.append(monitor.toString() + "\n");
        if (monitor.succeeded() && size != null) {
            out.append( String.format("Produced %d triples, duration %dms\n\n", size.longValue(), duration) );
        } else {
            out.append("Duration: " + duration + "ms\n\n");
            
        }
        for (ProgressMessage message : monitor.getMessages()) {
            out.append( message.toString() + "\n" );
        }
        return out.toString();
    }
}
