// Default-application bindings for developer file types.
//
// Reads file-associations.txt and points every extension in it at one editor,
// via LaunchServices. Invoked by file-associations.sh; see that script and the
// .txt file for the why.
//
// Run as a script (`swift file-associations.swift ...`), never compiled into a
// committed binary. /usr/bin/swift is Apple-signed, and that matters: the same
// LSSetDefaultRoleHandlerForContentType call made from an ad-hoc-signed binary
// (duti, for one) makes LaunchServices raise a per-extension "keep using X?"
// confirmation panel, so a 205-entry run becomes 84 modal dialogs. Through
// /usr/bin/swift the identical calls apply silently. If this is ever rewritten
// as a compiled helper, expect the dialogs to come back.
//
// Usage:
//   swift file-associations.swift status <list> <bundle-id>
//   swift file-associations.swift apply  <list> <bundle-id>
//   swift file-associations.swift check  <ext>

import Foundation
import UniformTypeIdentifiers
import CoreServices

// Extensions whose UTI is owned by a media type. macOS gives .ts to MPEG-2
// transport streams and .mts to AVCHD video, so binding them to an editor also
// captures real video files. Both are accepted deliberately (TypeScript is far
// likelier on this machine than broadcast media), but nothing else is: any
// future addition that resolves to a movie/audio/image UTI is a mistake and is
// rejected rather than silently hijacking a media type.
let mediaAllowed: Set<String> = ["ts", "mts"]

func parseList(_ path: String) -> [String] {
    guard let raw = try? String(contentsOfFile: path, encoding: .utf8) else {
        FileHandle.standardError.write("cannot read list: \(path)\n".data(using: .utf8)!)
        exit(2)
    }
    var seen = Set<String>(), out = [String]()
    for line in raw.split(separator: "\n", omittingEmptySubsequences: false) {
        let e = line.trimmingCharacters(in: .whitespaces)
        if e.isEmpty || e.hasPrefix("#") { continue }
        if seen.insert(e).inserted { out.append(e) }
    }
    return out
}

func handler(for uti: String) -> String {
    LSCopyDefaultRoleHandlerForContentType(uti as CFString, .all)?
        .takeRetainedValue() as String? ?? ""
}

/// nil when safe; a reason string when the extension must not be bound.
func unsafeReason(_ ext: String, _ type: UTType) -> String? {
    if mediaAllowed.contains(ext) { return nil }
    if type.isDynamic { return nil }  // nothing claims it, nothing to hijack
    for bad: UTType in [.movie, .audio, .image, .audiovisualContent, .archive,
                        .presentation, .spreadsheet, .database] where type.conforms(to: bad) {
        return "resolves to \(type.identifier) (conforms to \(bad.identifier))"
    }
    return nil
}

func appExists(_ bundleID: String) -> Bool {
    LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?
        .takeRetainedValue() as? [URL] != nil
}

let args = CommandLine.arguments
guard args.count >= 2 else { print("usage: status|apply|check"); exit(2) }
let cmd = args[1]

// --- check: explain a single extension ---------------------------------------
if cmd == "check" {
    guard args.count >= 3 else { print("usage: check <ext>"); exit(2) }
    let ext = args[2].hasPrefix(".") ? String(args[2].dropFirst()) : args[2]
    guard let t = UTType(filenameExtension: ext) else {
        print("\(ext): no UTI could be derived"); exit(1)
    }
    let cur = handler(for: t.identifier)
    print("extension : \(ext)")
    print("UTI       : \(t.identifier)\(t.isDynamic ? "  (dynamic - no app declares this type)" : "")")
    print("handler   : \(cur.isEmpty ? "<none>" : cur)")
    if let why = unsafeReason(ext, t) { print("UNSAFE    : \(why)") }
    else { print("safe      : yes") }
    exit(0)
}

guard args.count >= 4 else { print("usage: \(cmd) <list> <bundle-id>"); exit(2) }
let listPath = args[2], bundleID = args[3]
let exts = parseList(listPath)

guard appExists(bundleID) else {
    // duti reported success for a bundle ID matching no installed app, which
    // silently reset the binding to whatever LaunchServices ranked next. Refuse.
    FileHandle.standardError.write("no installed application with bundle id \(bundleID)\n".data(using: .utf8)!)
    exit(2)
}

var wrong = [(String, String, String)]()   // ext, uti, current
var unresolved = [String](), rejected = [(String, String)]()
var utisToSet = [String: String]()          // uti -> first ext that wanted it

for ext in exts {
    guard let t = UTType(filenameExtension: ext) else { unresolved.append(ext); continue }
    if let why = unsafeReason(ext, t) { rejected.append((ext, why)); continue }
    let cur = handler(for: t.identifier)
    if cur.caseInsensitiveCompare(bundleID) == .orderedSame { continue }
    wrong.append((ext, t.identifier, cur.isEmpty ? "<none>" : cur))
    utisToSet[t.identifier] = ext
}

if cmd == "status" {
    print("list      : \(exts.count) extensions")
    print("target    : \(bundleID)")
    print("correct   : \(exts.count - wrong.count - unresolved.count - rejected.count)")
    print("to change : \(wrong.count) extensions (\(utisToSet.count) distinct UTIs)")
    func pad(_ s: String, _ n: Int) -> String {
        s.count >= n ? s : s + String(repeating: " ", count: n - s.count)
    }
    for (e, u, c) in wrong.sorted(by: { $0.0 < $1.0 }) {
        print("    \(pad(e, 14)) \(pad(u, 46)) \(c)")
    }
    for e in unresolved { print("    ! \(e): no UTI") }
    for (e, why) in rejected { print("    ! \(e): \(why)") }
    exit(wrong.isEmpty && rejected.isEmpty && unresolved.isEmpty ? 0 : 1)
}

if cmd == "apply" {
    if !rejected.isEmpty {
        for (e, why) in rejected {
            FileHandle.standardError.write("refusing \(e): \(why)\n".data(using: .utf8)!)
        }
        exit(2)
    }
    var failed = 0
    for (uti, _) in utisToSet {
        if LSSetDefaultRoleHandlerForContentType(uti as CFString, .all, bundleID as CFString) != noErr {
            failed += 1
            FileHandle.standardError.write("failed to set \(uti)\n".data(using: .utf8)!)
        }
    }
    print("queued \(utisToSet.count - failed) UTI(s) for \(bundleID) (\(wrong.count) extensions)")
    for e in unresolved { print("  skipped \(e): no UTI could be derived") }

    // LSSetDefaultRoleHandlerForContentType returns noErr the moment lsd accepts
    // the change, not when it applies it. The daemon then drains its queue at
    // roughly 1.7 UTIs/sec, so a full run takes ~95s and a read-back any sooner
    // reports the old handlers and looks like total failure. Poll to convergence
    // rather than sleeping a fixed amount, and give up only once progress stops.
    let wanted = Array(utisToSet.keys)
    var settled = 0, stagnant = 0, deadline = 0
    while deadline < 60 {
        let done = wanted.filter { handler(for: $0).caseInsensitiveCompare(bundleID) == .orderedSame }.count
        if done == wanted.count { settled = done; break }
        if done == settled { stagnant += 1 } else { stagnant = 0 }
        settled = done
        if stagnant >= 6 { break }   // 30s with no movement: lsd is done trying
        FileHandle.standardError.write("  \(done)/\(wanted.count) applied...\r".data(using: .utf8)!)
        RunLoop.current.run(until: Date().addingTimeInterval(5))
        deadline += 1
    }
    print("applied \(settled)/\(wanted.count) UTI(s)")
    exit(failed == 0 && settled == wanted.count ? 0 : 1)
}

print("unknown command: \(cmd)")
exit(2)
