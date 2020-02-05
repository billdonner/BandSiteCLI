//
//  main.swift
//  grubler
//
//  Created by william donner on 1/29/20.
//  Copyright © 2020 midnightrambler. All rights reserved.
//


import Foundation
import BandSite
import LinkGrubber
import HTMLExtractor


let LOGGING_LEVEL = LoggingLevel.none


public struct  FileTypeFuncs:BandSiteProt {
    
    var bandfacts:BandInfo
    public init(bandfacts:BandInfo) {self.bandfacts = bandfacts}
    
    
    public func pageMakerFunc(_ props: CustomPageProps, _ links: [Fav]) throws {
       let _    = try AudioHTMLSupport(bandinfo: bandfacts,
                                   lgFuncs: self ).audioListPageMakerFunc(props:props,links:links)
    }
    
    public func matchingFunc(_ u: URL) -> Bool {
        return  u.absoluteString.hasPrefix(bandfacts.matchingURLPrefix)
    }
    
    public func scrapeAndAbsorbFunc ( theURL:URL, html:String ) throws ->  ScrapeAndAbsorbBlock {
        let x   = HTMLExtractor.extractFrom (  html:html )
        return HTMLExtractor.converttoScrapeAndAbsorbBlock(x,relativeTo:theURL)
    }

    public func isImageExtensionFunc (_ s:String) -> Bool {
         ["jpg","jpeg","png"].includes(s)
     }

    public func isAudioExtensionFunc(_ s:String) -> Bool {
        ["mp3","mpeg","wav"].includes(s)
    }
    public func isMarkdownExtensionFunc(_ s:String) -> Bool{
        ["md", "markdown", "txt", "text"].includes(s)
    }
    public func isNoteworthyExtensionFunc(_ s: String) -> Bool {
        isImageExtensionFunc(s) || isMarkdownExtensionFunc(s)
    }
   public  func isInterestingExtensionFunc (_ s:String) -> Bool {
        isImageExtensionFunc(s) || isAudioExtensionFunc(s)
    }
}


func printUsage() {
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    print("\(executableName) 1.0.2 ")
    print("usage:")
    print("\(executableName) root-url output-file-path [-verbose]")
}

func exitBadCommand() {
    print("[grubler] Bad Command ") //\(CommandLine.arguments)")
    printUsage()
}
guard CommandLine.arguments.count > 2 else { exitBadCommand(); exit(0)  }

let dirpath = CommandLine.arguments[2]//"/Users/williamdonner/hd"

let bandfacts = BandInfo(
    crawlTags: ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light","love"],
    pathToContentDir: dirpath + "/Content",
    pathToOutputDir: dirpath + "/Resources/BigData",
    matchingURLPrefix:  "https://billdonner.com/halfdead" ,
    specialFolderPaths: ["/audiosessions","/favorites"],
    shortname: "ABHD" )


    // places to test, or simply to use
    func command_rewriter(c:String)->URL {
        let url = URL(string:CommandLine.arguments[1])
        guard let nrl  = url else { print("bad rooturl"); exit(0)}
            print("[grubler] grubbing: \(nrl)")
        return nrl
    }
    
// this will run for a bit while crawlinig the internect, it generates .MD files
generateBandSite(bandinfo:bandfacts,
                 rewriter:command_rewriter,
                 lgFuncs: FileTypeFuncs(bandfacts:bandfacts),
                 logLevel: LOGGING_LEVEL)
print("[grubler] all done")

