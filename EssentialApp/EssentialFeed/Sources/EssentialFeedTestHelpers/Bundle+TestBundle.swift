import Foundation
@testable import EssentialFeed

public extension EssentialFeedBundle {
    static var testBundle: Bundle {
        return swiftPackageBundle_builtForTests ?? EssentialFeedBundle.get
    }
    
    private static let bundleName = "EssentialFeed_EssentialFeed.bundle"

    private static var swiftPackageBundle_builtForTests: Bundle? {
        let bundle = Bundle(for: EssentialFeed.ManagedCache.self)
        
        if bundle.bundleURL.absoluteString.contains(bundleName) {
            return bundle
        }
        
        let targetString = bundle.bundleURL.absoluteString
        let macosSplitter = "/Debug/"
        let iosSplitter = "/Debug-iphonesimulator/"
        
        let splitter = bundle.bundleURL.absoluteString.contains(iosSplitter) ? iosSplitter : macosSplitter
        
        let components = targetString.components(separatedBy: splitter)
        let urlString = "\(components[0])" + splitter + bundleName
        
        if let url = URL(string: urlString) {
            return Bundle(url: url)
        }
        
        return nil
    }
}
