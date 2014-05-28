// If the document isn't at a location matching urlPattern then rewrite all a href links 
// which do match urlPattern to point to the same server as this document
// Assumes jQuery
$(function() {
    var hostPattern = /^https?:\/\/([^\/]*)/;
    var pathPattern = /^https?:\/\/[^\/]*(.*)/;
    var schemePattern = /(^https?:\/\/).*/;
    var collectionPattern = /^https?:\/\/[^\/]*\/([^\/]*).*$/ ;
    
    var url = document.URL;
    var requestHost = url.match(hostPattern)[1];
    var requestScheme = url.match(schemePattern)[1];
    
    $("a[href]").each ( function (a) {
         var targetHost = this.href.match(hostPattern);
         var targetPath = this.href.match(pathPattern);
         var targetCollection    = this.href.match(collectionPattern);
         
         targetHost = targetHost!=null ? targetHost[1] : null ;
         targetPath = targetPath!=null ? targetPath[1] : null ;
         targetCollection = targetCollection!=null ? targetCollection[1] : null;
         
         if(targetHost != null &&
            targetHost == "reference.data.gov.uk"  
           ) {
             this.href = this.href.replace(this.href,requestScheme+requestHost+targetPath) ;
         };   
    });
});