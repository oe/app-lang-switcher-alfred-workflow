#!/usr/bin/env swift

import Foundation

class Workflow {
    
    init() {}
    
    func run () {
        do {
            guard let appPath = appPath else {
                let emptyItem = AlfredItem(title: "unable to retrieve current app path")
                prettyPrint(AlfredResult(items: [emptyItem]))
                return
            }
            let langs = try getAppLangs(appPath)
            let bundleID = try getBundleId(appPath: appPath)
            let items = convert2LangResult(langs, appPath: appPath, bundleID: bundleID)
            let result = AlfredResult(items: items)
            prettyPrint(result)
        } catch {
            prettyPrint(AlfredResult(items: [
                AlfredItem(title: "unable to load languages", subtitle: error.localizedDescription)
            ]))
        }
    }
    
    func convert2LangResult(_ langs: [String], appPath: URL, bundleID: String) -> [AlfredItem] {
        let appCliPath = appPath.appendingPathComponent("Contents/MacOS/\(getFileName(path: appPath))").path
        if langs.count < 2 {
            return [AlfredItem(title: "No Available Language!")]
        }
        return langs.map { lang in
            let arg = "defaults write \(bundleID) AppleLanguages '(\"\(lang)\")' && open \(appPath)"
            let cmd = AlfredItemModCmd(valid: true, arg: arg, subtitle: "Set as Default Language & Launch")
            let mod = AlfredItemMod(cmd: cmd)
            let title = Self.langDict[lang] ?? lang
            return AlfredItem(
                title: title,
                subtitle: "Launch App in This Language",
                match: getKeywords([title, lang]),
                arg: "\"\(appCliPath)\" -AppleLanguages '(\(lang))'",
                mods: mod
            )
        }
    }
    
    func getKeywords(_ strings: [String]) -> String {
        strings.map { $0.replacingOccurrences(of: #"[_\-\(\)]"#, with: " ", options: .regularExpression, range: nil) }.joined(separator: " ")
    }
    
    var appPath: URL? {
        guard let path = ProcessInfo.processInfo.environment["AppPath"] else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
    
    func getAppLangs(_ appPath: URL) throws -> [String] {
        let items = try FileManager.default.contentsOfDirectory(atPath: appPath.appendingPathComponent("Contents/Resources").path)
        let suffix = ".lproj"
        return items.filter { $0.hasSuffix(suffix) }.map { String($0.dropLast(suffix.count)) }.filter { $0 != "Base" }
    }
    
    func getFileName(path: URL) -> String {
        return path.deletingPathExtension().lastPathComponent
    }
    
    func getBundleId(appPath: URL) throws -> String {
        try runCmd("mdls", ["-name", "kMDItemCFBundleIdentifier", "-r", appPath.path])
    }
    
    func getSysLang() throws -> String {
        try runCmd("defaults", ["read", ".GlobalPreferences", "AppleLanguages"])
    }
    
    func prettyPrint<T: Encodable>(_ v: T) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(v) else {
            return
        }
        print(String(data: data, encoding: .utf8)!)
    }
    
    func runCmd(_ cmd: String, _ args: [String] = []) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        var fullArgs = [ cmd ]
        fullArgs.append(contentsOf: args)
        process.arguments = fullArgs
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            }
            throw CmdError.emptyOutput
        } catch {
            print("error", error.localizedDescription)
            if error is CmdError {
                throw error
            }
            throw CmdError.cmdError(msg: error.localizedDescription)
        }
    }
    
    struct AlfredResult: Codable {
        var items: [AlfredItem]
    }
    
    struct AlfredItem: Codable {
        var title: String
        var subtitle: String?
        var match: String?
        var arg: String?
        var mods: AlfredItemMod?
    }
    
    struct AlfredItemMod: Codable {
        var cmd: AlfredItemModCmd
    }
    
    struct AlfredItemModCmd: Codable {
        var valid: Bool
        var arg: String
        var subtitle: String
    }
    
    static let langDict: [String: String] = [
        "he": "Hebrew",
        "ar": "Arabic",
        "el": "Greek",
        "ja": "Japanese",
        "da": "Danish",
        "sk": "Slovak",
        "pt_PT": "Portuguese",
        "cs": "Czech",
        "ko": "Korean",
        "no": "Norwegian",
        "hu": "Hungarian",
        "tr": "Turkish",
        "pl": "Polish",
        "ru": "Russian",
        "fi": "Finnish",
        "id": "Indonesian",
        "nl": "Dutch",
        "th": "Thai",
        "pt": "Portuguese",
        "de": "German",
        "en": "English",
        "en_GB": "English (UK)",
        "en_US": "English (US)",
        "en_AU": "English (AU)",
        "pt_BR": "Portuguese-BR",
        "es": "Spanish",
        "it": "Italian",
        "sv": "Swedish",
        "fr": "French",
        "fr_CA": "French (CA-Canada)",
        "hr": "Croatian",
        "zh": "Chinese",
        "hi": "Hindi",
        "ca": "Catalan",
        "uk": "Ukrainian",
        "ms": "Malaysian",
        "vi": "Vietnamese",
        "ro": "Romanian",
        "es_419": "Latin American Spanish",
        "zh-Hans": "Chinese (Simplified)",
        "zh-Hant": "Chinese (Traditional)",
        "zh_CN": "Chinese (Simplified)",
        "zh_TW": "Chinese (TW Traditional)",
        "zh_HK": "Chinese (HK Traditional)"
    ]
    
    enum CmdError: Error {
        case cmdError(msg: String)
        case emptyOutput
    }
    
}

Workflow().run()
