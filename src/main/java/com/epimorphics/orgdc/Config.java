/******************************************************************
 * File:        Config.java
 * Created by:  Dave Reynolds
 * Created on:  16 May 2014
 * 
 * (c) Copyright 2014, Epimorphics Limited
 *
 *****************************************************************/

package com.epimorphics.orgdc;

import com.epimorphics.appbase.core.ComponentBase;
import com.epimorphics.dclib.framework.ConverterService;

public class Config extends ComponentBase {
    protected String traceDir;
    protected ConverterService service;

    public String getTraceDir() {
        return traceDir;
    }

    public void setTraceDir(String traceDir) {
        this.traceDir = traceDir;
    }

    public ConverterService getService() {
        return service;
    }

    public void setService(ConverterService service) {
        this.service = service;
    }
    
    
    
}
